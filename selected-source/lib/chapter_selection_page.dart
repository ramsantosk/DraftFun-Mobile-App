import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'landing_page.dart';
import 'pages/chapter1_page.dart';
import 'pages/chapter2_page.dart';
import 'pages/chapter3_page.dart';
import 'pages/chapter4_page.dart';
import 'background_music_service.dart';

class ChapterSelectionPage extends StatefulWidget {
  const ChapterSelectionPage({super.key});

  @override
  State<ChapterSelectionPage> createState() =>
      _ChapterSelectionPageState();
}

class _ChapterSelectionPageState
    extends State<ChapterSelectionPage> {
  static const _green = Color(0xFF167A00);

  final AudioPlayer _sfxPlayer = AudioPlayer();
  bool _soundEffects = true;
  double _soundEffectsVolume = 1.0;

Future<void> _playChapterClick() async {
  if (!_soundEffects) return;

  await _sfxPlayer.stop();
  await _sfxPlayer.setVolume(_soundEffectsVolume);

  await _sfxPlayer.play(
    AssetSource('sfx/click_chapter.mp3')
  );
}

Future<void> _playButtonClick() async {
  if (!_soundEffects) return;

  await _sfxPlayer.stop();
  await _sfxPlayer.setVolume(_soundEffectsVolume);

  await _sfxPlayer.play(
    AssetSource('sfx/button_click.mp3')
  );
}

  bool _loading = true;

  bool _chapter2Unlocked = false;
  bool _chapter3Unlocked = false;
  bool _chapter4Unlocked = false;
  bool _isNavigating = false;

Future<void> _loadSoundSettings() async {
  final prefs = await SharedPreferences.getInstance();

  _soundEffects =
      prefs.getBool('soundEffects') ?? true;

  _soundEffectsVolume =
      prefs.getDouble('soundEffectsVolume') ?? 1.0;
}

@override
void initState() {
  super.initState();

  _loadSoundSettings();
  _loadChapterProgress();

  BackgroundMusicService.instance.stopMusic();
}

@override
void didChangeDependencies() {
  super.didChangeDependencies();
  _loadSoundSettings();
}
  Future<void> _loadChapterProgress() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
    return;
  }

  try {
    final chapter1Doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('chapter_progress')
        .doc('chapter1')
        .get();

    final chapter2Doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('chapter_progress')
        .doc('chapter2')
        .get();

    final chapter3Doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('chapter_progress')
        .doc('chapter3')
        .get();

    if (!mounted) return;

    final chapter1Data = chapter1Doc.data();
    final chapter2Data = chapter2Doc.data();
    final chapter3Data = chapter3Doc.data();

    setState(() {
  _chapter2Unlocked =
      chapter1Data?['chapter2Unlocked'] == true;

  _chapter3Unlocked =
      chapter2Data?['chapter3Unlocked'] == true;

  _chapter4Unlocked =
      chapter3Data?['chapter4Unlocked'] == true;

  _loading = false;
});
  } catch (e) {
    debugPrint('Error loading chapter progress: $e');

    if (!mounted) return;

    setState(() {
      _loading = false;
    });
  }
}

@override
void dispose() {
  _sfxPlayer.dispose();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/ChapterBG.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x99000000),
              ),
            ),

            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact =
                      constraints.maxWidth < 620;

                  final panelWidth = compact
                      ? constraints.maxWidth - 36
                      : constraints.maxWidth.clamp(
                          420.0,
                          620.0,
                        );

                  return Center(
                    child: Container(
                      width: panelWidth,
                      padding: EdgeInsets.fromLTRB(
                        compact ? 10 : 12,
                        0,
                        compact ? 10 : 12,
                        compact ? 18 : 24,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(
                          alpha: 0.78,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHeader(
                            context,
                            compact,
                          ),

                          const SizedBox(height: 8),

                          if (_loading)
                            const SizedBox(
                              height: 350,
                              child: Center(
                                child:
                                    CircularProgressIndicator(
                                  color: Color(
                                    0xFF70F24A,
                                  ),
                                ),
                              ),
                            )
                          else
                            _buildChapterGrid(
                              compact,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool compact,
  ) {
    return Container(
      height: compact ? 58 : 68,
      decoration: const BoxDecoration(
        color: _green,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(14),
          bottomRight: Radius.circular(14),
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 8,
            ),
            child: IconButton(
              tooltip: 'Back',
onPressed: _isNavigating
    ? null
    : () async {
        setState(() => _isNavigating = true);
        _playButtonClick();
        await BackgroundMusicService.instance.startMusic(volume: 0.6);
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(
            builder: (context) => const LandingPage(),
          ),
          (route) => false,
        );
      },
              icon: const Icon(
                Icons.arrow_back_rounded,
                size: 30,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _green,
                minimumSize: const Size(
                  48,
                  48,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          Expanded(
            child: Text(
              'SELECTION OF LESSON',
              textAlign: TextAlign.center,
              style: GoogleFonts.vastShadow(
                color: Colors.white,
                fontSize: compact ? 17 : 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildChapterGrid(bool compact) {
    final chapters = [
      _ChapterData(
        title: 'CHAPTER 1',
        locked: false,
        chapterNumber: 1,
      ),
      _ChapterData(
        title: 'CHAPTER 2',
        locked: !_chapter2Unlocked,
        chapterNumber: 2,
      ),
      _ChapterData(
        title: 'CHAPTER 3',
        locked: !_chapter3Unlocked,
        chapterNumber: 3,
      ),
      _ChapterData(
        title: 'CHAPTER 4',
        locked: !_chapter4Unlocked,
        chapterNumber: 4,
      ),
    ];

return GridView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  itemCount: chapters.length,
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: compact ? 10 : 12,
    mainAxisSpacing: compact ? 10 : 14,
    mainAxisExtent: compact ? 105 : 115,
  ),
      itemBuilder: (context, index) {
        final chapter = chapters[index];

return _ChapterCard(
  title: chapter.title,
  locked: chapter.locked,
  onTap: () async {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);
    _playChapterClick();
    try {
      await _openChapter(chapter.chapterNumber);
    } finally {
      if (mounted) setState(() => _isNavigating = false);
    }
  },
);
      },
    );
  }

Future<void> _openChapter(int chapterNumber) async {
  await BackgroundMusicService.instance.startMusic(
    volume: 0.10,
  );

  if (chapterNumber == 1) {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const Chapter1Page(),
      ),
    );

    await BackgroundMusicService.instance.stopMusic();
    return;
  }

  if (chapterNumber == 2) {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const Chapter2Page(),
      ),
    );

    await BackgroundMusicService.instance.stopMusic();
    return;
  }

  if (chapterNumber == 3) {
    final completed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => const Chapter3Page(),
      ),
    );

    await BackgroundMusicService.instance.stopMusic();

    if (completed == true && mounted) {
      _loadChapterProgress();
    }

    return;
  }

  if (chapterNumber == 4) {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const Chapter4Page(),
      ),
    );

    await BackgroundMusicService.instance.stopMusic();
    return;
  }
}
    }

// CHAPTER DATA


class _ChapterData {
  const _ChapterData({
    required this.title,
    required this.locked,
    required this.chapterNumber,
  });

  final String title;
  final bool locked;
  final int chapterNumber;
}


// CHAPTER CARD

class _ChapterCard extends StatefulWidget {
  const _ChapterCard({
    required this.title,
    required this.locked,
    required this.onTap,
  });

  final String title;
  final bool locked;
  final VoidCallback onTap;

  @override
  State<_ChapterCard> createState() =>
      _ChapterCardState();
}

class _ChapterCardState
    extends State<_ChapterCard> {
  bool _hovering = false;
  bool _tapLocked = false;

  @override
  Widget build(BuildContext context) {
    final active =
        !widget.locked && _hovering;

    return MouseRegion(
      cursor: SystemMouseCursors.click,

      onEnter: widget.locked
          ? null
          : (_) {
              setState(() {
                _hovering = true;
              });
            },

      onExit: widget.locked
          ? null
          : (_) {
              setState(() {
                _hovering = false;
              });
            },

      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFFB7F34A)
              : Colors.white,
          borderRadius:
              BorderRadius.circular(20),
          boxShadow: active
              ? [
                  BoxShadow(
                    color:
                        const Color(0xFF70F24A)
                            .withValues(
                      alpha: 0.30,
                    ),
                    blurRadius: 20,
                    spreadRadius: 3,
                  ),
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius:
              BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              if (widget.locked) {
                final chapterNumber = int.tryParse(
                  widget.title.replaceAll(RegExp(r'[^0-9]'), ''),
                );
                final previous = chapterNumber == null || chapterNumber <= 1
                    ? null
                    : chapterNumber - 1;
                final message = previous == null
                    ? 'This chapter is currently locked.'
                    : 'Complete Chapter $previous to unlock ${widget.title}.';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message)),
                );
                return;
              }
              if (_tapLocked) return;
              setState(() => _tapLocked = true);
              widget.onTap();
              Future.delayed(const Duration(milliseconds: 700), () {
                if (mounted) setState(() => _tapLocked = false);
              });
            },
            hoverColor: const Color(
              0xFFB7F34A,
            ),
            highlightColor:
                const Color(0xFF70F24A)
                    .withValues(
              alpha: 0.7,
            ),
            splashColor:
                const Color(0xFF70F24A)
                    .withValues(
              alpha: 0.8,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style:
                      GoogleFonts.vastShadow(
                    color: widget.locked
                        ? Colors.grey.shade600
                        : Colors.black,
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                if (widget.locked)
                  const Positioned(
                    bottom: 18,
                    child: Icon(
                      Icons.lock,
                      color: Color(
                        0xFF70F24A,
                      ),
                      size: 48,
                      shadows: [
                        Shadow(
                          color: Colors.white,
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
