import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kRed = Color(0xFFFF2A2A);
const kDarkRed = Color(0xFF8B0000);
const kBlack = Color(0xFF0D0000);
const kPanel = Color(0xFF260404);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const AlpyApp());
}

void toast(BuildContext context, String text) {
  final m = ScaffoldMessenger.of(context);
  m.hideCurrentSnackBar();
  m.showSnackBar(SnackBar(
    backgroundColor: kDarkRed,
    duration: const Duration(seconds: 2),
    content: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
  ));
}

class AlpyApp extends StatelessWidget {
  const AlpyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Alpy Misali Vidio',
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Minecraft',
        scaffoldBackgroundColor: kBlack,
        colorScheme: const ColorScheme.dark(primary: kRed, secondary: kRed),
        sliderTheme: const SliderThemeData(
          activeTrackColor: kRed,
          inactiveTrackColor: kDarkRed,
          thumbColor: kRed,
          overlayColor: Color(0x33FF2A2A),
          trackShape: RectangularSliderTrackShape(),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// ---------- Piksel ikonlar ----------

class Ico {
  static const List<String> photo = [
    "###########",
    "#.........#",
    "#.....#...#",
    "#....###..#",
    "#.#...#...#",
    "###.......#",
    "#####..#..#",
    "#######.###",
    "#.........#",
    "###########",
    "...........",
  ];
  static const List<String> video = [
    "...........",
    "...........",
    "#########..",
    "#.......#.#",
    "#.......##.",
    "#.......###",
    "#.......##.",
    "#.......#.#",
    "#########..",
    "...........",
    "...........",
  ];
  static const List<String> back = [
    "...........",
    "....#......",
    "...##......",
    "..###......",
    ".##########",
    "..###......",
    "...##......",
    "....#......",
    "...........",
    "...........",
    "...........",
  ];
  static const List<String> undo = [
    "...........",
    "..#........",
    ".##........",
    "###########",
    ".##.......#",
    "..#.......#",
    "..........#",
    "..#.......#",
    "..#########",
    "...........",
    "...........",
  ];
  static const List<String> save = [
    "...........",
    "#########..",
    "#.#####.##.",
    "#.#####.###",
    "#.......###",
    "#.#####.###",
    "#.#...#.###",
    "#.#...#.###",
    "###########",
    "...........",
    "...........",
  ];
  static const List<String> rotate = [
    "...........",
    "...#####...",
    "..#.....#.#",
    ".#.......##",
    ".#......###",
    ".#.........",
    ".#.......#.",
    "..#.....#..",
    "...#####...",
    "...........",
    "...........",
  ];
  static const List<String> flip = [
    "...........",
    "..#.....#..",
    ".##..#..##.",
    "###..#..###",
    ".##..#..##.",
    "..#..#..#..",
    "..#.....#..",
    "...........",
    "...........",
    "...........",
    "...........",
  ];
  static const List<String> adjust = [
    "...........",
    "..#........",
    "#####.#####",
    "..#........",
    "...........",
    "#####.#####",
    "......#....",
    "......#....",
    "...........",
    "...........",
    "...........",
  ];
  static const List<String> filter = [
    "...........",
    ".....#.....",
    "....###....",
    "...#####...",
    "..#######..",
    ".#########.",
    ".#########.",
    "..#######..",
    "...#####...",
    "...........",
    "...........",
  ];
  static const List<String> trash = [
    "....###....",
    "###########",
    "...........",
    ".#########.",
    ".#.#.#.#.#.",
    ".#.#.#.#.#.",
    ".#.#.#.#.#.",
    ".#.#.#.#.#.",
    ".#########.",
    "...........",
    "...........",
  ];
  static const List<String> plus = [
    "....###....",
    "....###....",
    "....###....",
    "###########",
    "###########",
    "###########",
    "....###....",
    "....###....",
    "....###....",
    "...........",
    "...........",
  ];
}

class PixelIcon extends StatelessWidget {
  final List<String> rows;
  final Color color;
  final double size;
  const PixelIcon(this.rows, {super.key, this.color = kRed, this.size = 28});
  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _PixelPainter(rows, color));
  }
}

class _PixelPainter extends CustomPainter {
  final List<String> rows;
  final Color color;
  _PixelPainter(this.rows, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final h = rows.length;
    final w = rows[0].length;
    final px = size.width / w;
    final offY = (size.height - h * px) / 2;
    final p = Paint()
      ..color = color
      ..isAntiAlias = false;
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        if (rows[y][x] == '#') {
          canvas.drawRect(Rect.fromLTWH(x * px, offY + y * px, px + 0.5, px + 0.5), p);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_PixelPainter old) => old.color != color || old.rows != rows;
}

class IconTap extends StatelessWidget {
  final List<String> icon;
  final VoidCallback? onTap;
  final double size;
  const IconTap({super.key, required this.icon, required this.onTap, this.size = 28});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: PixelIcon(icon, size: size, color: onTap == null ? kDarkRed : kRed),
      ),
    );
  }
}

class PixelButton extends StatelessWidget {
  final String label;
  final List<String>? icon;
  final VoidCallback onTap;
  final bool filled;
  final double fontSize;
  const PixelButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.filled = true,
    this.fontSize = 20,
  });
  @override
  Widget build(BuildContext context) {
    final fg = filled ? Colors.white : kRed;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: filled ? kRed : const Color(0x99000000),
          border: Border.all(color: kRed, width: 3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              PixelIcon(icon!, color: fg, size: fontSize + 6),
              const SizedBox(width: 10),
            ],
            Text(label, style: TextStyle(color: fg, fontSize: fontSize)),
          ],
        ),
      ),
    );
  }
}

// ---------- Ana ekran ----------

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _bgPath;

  @override
  void initState() {
    super.initState();
    _loadBg();
  }

  Future<void> _loadBg() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('bg');
    if (path != null && File(path).existsSync() && mounted) {
      setState(() => _bgPath = path);
    }
  }

  Future<void> _pickBg() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (x == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final dest = '${dir.path}/bg_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(x.path).copy(dest);
    final prefs = await SharedPreferences.getInstance();
    final old = prefs.getString('bg');
    await prefs.setString('bg', dest);
    if (old != null) {
      try {
        await File(old).delete();
      } catch (_) {}
    }
    if (mounted) setState(() => _bgPath = dest);
  }

  Future<void> _clearBg() async {
    final prefs = await SharedPreferences.getInstance();
    final old = prefs.getString('bg');
    await prefs.remove('bg');
    if (old != null) {
      try {
        await File(old).delete();
      } catch (_) {}
    }
    if (mounted) setState(() => _bgPath = null);
  }

  Future<void> _newProject() async {
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: kPanel,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: kRed, width: 3),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Yeni Proje',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: kRed, fontSize: 26)),
              const SizedBox(height: 16),
              PixelButton(
                label: 'Fotoğraf',
                icon: Ico.photo,
                onTap: () => Navigator.pop(ctx, 'photo'),
              ),
              const SizedBox(height: 12),
              PixelButton(
                label: 'Video',
                icon: Ico.video,
                onTap: () => Navigator.pop(ctx, 'video'),
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted) return;
    if (choice == 'photo') {
      final x = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (x == null || !mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PhotoEditor(file: File(x.path))),
      );
    } else if (choice == 'video') {
      toast(context, 'Video bölümü çok yakında!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_bgPath != null)
            Image.file(
              File(_bgPath!),
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => const SizedBox(),
            )
          else
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [kBlack, Color(0xFF4A0000)],
                ),
              ),
            ),
          Container(color: const Color(0x66000000)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      PixelButton(
                        label: 'Arka Plan',
                        icon: Ico.photo,
                        filled: false,
                        fontSize: 14,
                        onTap: _pickBg,
                      ),
                      if (_bgPath != null) IconTap(icon: Ico.trash, onTap: _clearBg),
                    ],
                  ),
                  const Spacer(),
                  const Text(
                    'Alpy Misali Vidio ❤️',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: kRed,
                      fontSize: 36,
                      shadows: [Shadow(color: Colors.black, offset: Offset(3, 3))],
                    ),
                  ),
                  const SizedBox(height: 28),
                  PixelButton(
                    label: 'Yeni Proje',
                    icon: Ico.plus,
                    fontSize: 26,
                    onTap: _newProject,
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Fotoğraf editörü ----------

class FilterDef {
  final String name;
  final List<double> matrix;
  const FilterDef(this.name, this.matrix);
}

const List<FilterDef> kFilters = [
  FilterDef('Normal', [
    1, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 0, 1, 0,
  ]),
  FilterDef('Siyah Beyaz', [
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0, 0, 0, 1, 0,
  ]),
  FilterDef('Kırmızı', [
    1.3, 0.1, 0, 0, 0,
    0, 0.55, 0, 0, 0,
    0, 0, 0.55, 0, 0,
    0, 0, 0, 1, 0,
  ]),
  FilterDef('Sepya', [
    0.393, 0.769, 0.189, 0, 0,
    0.349, 0.686, 0.168, 0, 0,
    0.272, 0.534, 0.131, 0, 0,
    0, 0, 0, 1, 0,
  ]),
  FilterDef('Soğuk', [
    0.9, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 1.25, 0, 0,
    0, 0, 0, 1, 0,
  ]),
  FilterDef('Sıcak', [
    1.2, 0, 0, 0, 10,
    0, 1, 0, 0, 0,
    0, 0, 0.8, 0, 0,
    0, 0, 0, 1, 0,
  ]),
  FilterDef('Negatif', [
    -1, 0, 0, 0, 255,
    0, -1, 0, 0, 255,
    0, 0, -1, 0, 255,
    0, 0, 0, 1, 0,
  ]),
  FilterDef('Soluk', [
    0.85, 0, 0, 0, 30,
    0, 0.85, 0, 0, 30,
    0, 0, 0.85, 0, 30,
    0, 0, 0, 1, 0,
  ]),
  FilterDef('Gece', [
    0.6, 0, 0, 0, 0,
    0, 0.7, 0, 0, 0,
    0, 0, 1, 0, 10,
    0, 0, 0, 1, 0,
  ]),
];

class _Edit {
  final int turns;
  final bool flipH;
  final bool flipV;
  final double b;
  final double c;
  final double s;
  final int filter;
  const _Edit({
    this.turns = 0,
    this.flipH = false,
    this.flipV = false,
    this.b = 0,
    this.c = 0,
    this.s = 0,
    this.filter = 0,
  });
  _Edit copyWith({
    int? turns,
    bool? flipH,
    bool? flipV,
    double? b,
    double? c,
    double? s,
    int? filter,
  }) {
    return _Edit(
      turns: turns ?? this.turns,
      flipH: flipH ?? this.flipH,
      flipV: flipV ?? this.flipV,
      b: b ?? this.b,
      c: c ?? this.c,
      s: s ?? this.s,
      filter: filter ?? this.filter,
    );
  }
}

// a(b(x)) hesaplar (4x5 renk matrisleri)
List<double> _mul(List<double> a, List<double> b) {
  final r = List<double>.filled(20, 0);
  for (var i = 0; i < 4; i++) {
    for (var j = 0; j < 5; j++) {
      var v = 0.0;
      for (var k = 0; k < 4; k++) {
        v += a[i * 5 + k] * b[k * 5 + j];
      }
      if (j == 4) v += a[i * 5 + 4];
      r[i * 5 + j] = v;
    }
  }
  return r;
}

List<double> _buildMatrix(_Edit e) {
  final bo = e.b * 2.55;
  final cf = (100 + e.c) / 100;
  final co = 128 * (1 - cf);
  final sat = (100 + e.s) / 100;
  const lr = 0.2126;
  const lg = 0.7152;
  const lb = 0.0722;
  final sr = (1 - sat) * lr;
  final sg = (1 - sat) * lg;
  final sb = (1 - sat) * lb;
  final bright = <double>[
    1, 0, 0, 0, bo,
    0, 1, 0, 0, bo,
    0, 0, 1, 0, bo,
    0, 0, 0, 1, 0,
  ];
  final contrast = <double>[
    cf, 0, 0, 0, co,
    0, cf, 0, 0, co,
    0, 0, cf, 0, co,
    0, 0, 0, 1, 0,
  ];
  final saturation = <double>[
    sr + sat, sg, sb, 0, 0,
    sr, sg + sat, sb, 0, 0,
    sr, sg, sb + sat, 0, 0,
    0, 0, 0, 1, 0,
  ];
  return _mul(kFilters[e.filter].matrix, _mul(saturation, _mul(contrast, bright)));
}

class PhotoEditor extends StatefulWidget {
  final File file;
  const PhotoEditor({super.key, required this.file});
  @override
  State<PhotoEditor> createState() => _PhotoEditorState();
}

class _PhotoEditorState extends State<PhotoEditor> {
  _Edit _cur = const _Edit();
  final List<_Edit> _undo = [];
  int _panel = 0; // 0 yok, 1 ayar, 2 filtre
  bool _saving = false;

  void _commit(_Edit e) {
    setState(() {
      _undo.add(_cur);
      _cur = e;
    });
  }

  void _undoLast() {
    if (_undo.isEmpty) return;
    setState(() {
      _cur = _undo.removeLast();
    });
  }

  Future<Uint8List> _render() async {
    final bytes = await widget.file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final img = frame.image;
    final rot = _cur.turns % 4;
    final swap = rot.isOdd;
    final w = swap ? img.height : img.width;
    final h = swap ? img.width : img.height;
    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec);
    canvas.translate(w / 2, h / 2);
    canvas.scale(_cur.flipH ? -1.0 : 1.0, _cur.flipV ? -1.0 : 1.0);
    canvas.rotate(rot * math.pi / 2);
    canvas.translate(-img.width / 2, -img.height / 2);
    final paint = Paint()
      ..colorFilter = ColorFilter.matrix(_buildMatrix(_cur))
      ..filterQuality = FilterQuality.high;
    canvas.drawImage(img, Offset.zero, paint);
    final out = await rec.endRecording().toImage(w, h);
    final data = await out.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final bytes = await _render();
      if (!await Gal.hasAccess()) {
        await Gal.requestAccess();
      }
      await Gal.putImageBytes(bytes);
      if (mounted) toast(context, 'Galeriye kaydedildi!');
    } catch (e) {
      if (mounted) toast(context, 'Kaydedilemedi :(');
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  IconTap(icon: Ico.back, onTap: () => Navigator.pop(context)),
                  const Expanded(
                    child: Center(
                      child: Text('Fotoğraf',
                          style: TextStyle(color: kRed, fontSize: 22)),
                    ),
                  ),
                  IconTap(
                    icon: Ico.undo,
                    onTap: _undo.isEmpty ? null : _undoLast,
                  ),
                  IconTap(icon: Ico.save, onTap: _save),
                ],
              ),
            ),
            if (_saving)
              const LinearProgressIndicator(color: kRed, backgroundColor: kDarkRed),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: ColorFiltered(
                  colorFilter: ColorFilter.matrix(_buildMatrix(_cur)),
                  child: Transform.scale(
                    scaleX: _cur.flipH ? -1.0 : 1.0,
                    scaleY: _cur.flipV ? -1.0 : 1.0,
                    child: RotatedBox(
                      quarterTurns: _cur.turns % 4,
                      child: Image.file(widget.file, fit: BoxFit.contain),
                    ),
                  ),
                ),
              ),
            ),
            if (_panel == 1) _adjustPanel(),
            if (_panel == 2) _filterPanel(),
            _toolBar(),
          ],
        ),
      ),
    );
  }

  Widget _slider(String label, double value, void Function(double) apply) {
    return Row(
      children: [
        SizedBox(
          width: 104,
          child: Text(label, style: const TextStyle(color: kRed, fontSize: 13)),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: -100,
            max: 100,
            onChangeStart: (_) => _undo.add(_cur),
            onChanged: (v) => setState(() => apply(v)),
          ),
        ),
        SizedBox(
          width: 36,
          child: Text('${value.round()}',
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white, fontSize: 13)),
        ),
      ],
    );
  }

  Widget _adjustPanel() {
    return Container(
      color: kPanel,
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _slider('Parlaklık', _cur.b, (v) => _cur = _cur.copyWith(b: v)),
          _slider('Kontrast', _cur.c, (v) => _cur = _cur.copyWith(c: v)),
          _slider('Doygunluk', _cur.s, (v) => _cur = _cur.copyWith(s: v)),
        ],
      ),
    );
  }

  Widget _filterPanel() {
    return Container(
      color: kPanel,
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        itemCount: kFilters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final sel = _cur.filter == i;
          return GestureDetector(
            onTap: () {
              if (!sel) _commit(_cur.copyWith(filter: i));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: sel ? kRed : Colors.transparent,
                border: Border.all(color: kRed, width: 2),
              ),
              child: Text(
                kFilters[i].name,
                style: TextStyle(color: sel ? Colors.white : kRed, fontSize: 14),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _tool(List<String> icon, String label, bool selected, VoidCallback onTap,
      {bool turned = false}) {
    final fg = selected ? Colors.white : kRed;
    Widget ic = PixelIcon(icon, color: fg, size: 26);
    if (turned) ic = RotatedBox(quarterTurns: 1, child: ic);
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          color: selected ? kDarkRed : Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ic,
              const SizedBox(height: 4),
              Text(label, style: TextStyle(color: fg, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toolBar() {
    return Container(
      color: kPanel,
      child: Row(
        children: [
          _tool(Ico.rotate, 'Döndür', false,
              () => _commit(_cur.copyWith(turns: (_cur.turns + 1) % 4))),
          _tool(Ico.flip, 'Aynala', _cur.flipH,
              () => _commit(_cur.copyWith(flipH: !_cur.flipH))),
          _tool(Ico.flip, 'Ters', _cur.flipV,
              () => _commit(_cur.copyWith(flipV: !_cur.flipV)),
              turned: true),
          _tool(Ico.adjust, 'Ayar', _panel == 1,
              () => setState(() => _panel = _panel == 1 ? 0 : 1)),
          _tool(Ico.filter, 'Filtre', _panel == 2,
              () => setState(() => _panel = _panel == 2 ? 0 : 2)),
        ],
      ),
    );
  }
}
