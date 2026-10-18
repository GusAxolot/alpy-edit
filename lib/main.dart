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
import 'video_editor.dart';

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
  static const List<String> crop = [
    "..#........",
    "..#........",
    "..#########",
    "..#.....#..",
    "..#.....#..",
    "..#.....#..",
    "..#.....#..",
    "..#.....#..",
    "#########..",
    "........#..",
    "........#..",
  ];
  static const List<String> text = [
    "...........",
    "###########",
    "###########",
    "....###....",
    "....###....",
    "....###....",
    "....###....",
    "....###....",
    "....###....",
    "....###....",
    "...........",
  ];
  static const List<String> brush = [
    "........##.",
    ".......###.",
    "......###..",
    ".....###...",
    "....###....",
    "...###.....",
    "..####.....",
    ".####......",
    "####.......",
    "###........",
    "...........",
  ];
  static const List<String> eraser = [
    "...........",
    "...........",
    "..#########",
    "..#...#...#",
    "..#...#...#",
    "..#...#...#",
    "..#...#...#",
    "..#########",
    "...........",
    "...........",
    "...........",
  ];
  static const List<String> resize = [
    "#####......",
    "#.#........",
    "#..#.......",
    "#...#......",
    "....#......",
    ".....#.....",
    "......#...#",
    ".......#..#",
    "........#.#",
    ".........##",
    "......#####",
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
      final x = await ImagePicker().pickVideo(source: ImageSource.gallery);
      if (x == null || !mounted) return;
      toast(context, 'Video hazırlanıyor...');
      final p = await createProjectFromVideo(x.path);
      if (!mounted) return;
      if (p == null) {
        toast(context, 'Video açılamadı');
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => VideoEditor(project: p)),
      );
    }
  }

  Future<void> _openProjects() async {
    final list = await listProjects();
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => Dialog(
          backgroundColor: kPanel,
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: kRed, width: 3),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Projelerim',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: kRed, fontSize: 24)),
                const SizedBox(height: 10),
                if (list.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('Henüz kayıtlı video projen yok',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 14)),
                  ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final p in list)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    Navigator.pop(ctx);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => VideoEditor(project: p),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: kRed, width: 2),
                                    ),
                                    child: Text(p.name,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 16)),
                                  ),
                                ),
                              ),
                              IconTap(
                                icon: Ico.trash,
                                onTap: () async {
                                  await deleteProject(p);
                                  setD(() => list.remove(p));
                                },
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                PixelButton(
                  label: 'Kapat',
                  filled: false,
                  fontSize: 16,
                  onTap: () => Navigator.pop(ctx),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
                  const SizedBox(height: 14),
                  PixelButton(
                    label: 'Projelerim',
                    icon: Ico.video,
                    filled: false,
                    fontSize: 18,
                    onTap: _openProjects,
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

const List<Color> kPalette = [
  Color(0xFFFFFFFF),
  Color(0xFF000000),
  kRed,
  Color(0xFFFF9800),
  Color(0xFFFFEB3B),
  Color(0xFF4CAF50),
  Color(0xFF2196F3),
  Color(0xFFE91E63),
];

double _cl(double v, double lo, double hi) => v < lo ? lo : (v > hi ? hi : v);

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

List<double> _buildMatrix(double br, double ct, double sa, int filter) {
  final bo = br * 2.55;
  final cf = (100 + ct) / 100;
  final co = 128 * (1 - cf);
  final sat = (100 + sa) / 100;
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
  return _mul(kFilters[filter].matrix, _mul(saturation, _mul(contrast, bright)));
}

// Yazı ve çıkartma katmanı
class EditLayer {
  final int id;
  final String text;
  final ui.Image? image;
  final double x;
  final double y;
  final double scale;
  final Color color;
  final bool shadow;
  final bool outline;
  const EditLayer({
    required this.id,
    this.text = '',
    this.image,
    required this.x,
    required this.y,
    required this.scale,
    this.color = const Color(0xFFFFFFFF),
    this.shadow = true,
    this.outline = true,
  });
  EditLayer copyWith({
    String? text,
    double? x,
    double? y,
    double? scale,
    Color? color,
    bool? shadow,
    bool? outline,
  }) {
    return EditLayer(
      id: id,
      text: text ?? this.text,
      image: image,
      x: x ?? this.x,
      y: y ?? this.y,
      scale: scale ?? this.scale,
      color: color ?? this.color,
      shadow: shadow ?? this.shadow,
      outline: outline ?? this.outline,
    );
  }
}

// Fırça / silgi çizgisi (resim pikselleriyle)
class PenStroke {
  final bool erase;
  final double width;
  final Color color;
  final List<Offset> pts;
  PenStroke(this.erase, this.width, this.color, this.pts);
}

class _Snap {
  final ui.Image img;
  final List<EditLayer> layers;
  final double b;
  final double c;
  final double s;
  final int filter;
  _Snap(this.img, this.layers, this.b, this.c, this.s, this.filter);
}

TextPainter _textPainter(EditLayer l, double w, {bool stroke = false}) {
  final fs = math.max(4.0, l.scale * w);
  final style = TextStyle(
    fontFamily: 'Minecraft',
    fontSize: fs,
    color: stroke ? null : l.color,
    foreground: stroke
        ? (Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = fs * 0.14
          ..strokeJoin = StrokeJoin.round
          ..color = const Color(0xFF000000))
        : null,
    shadows: (!stroke && l.shadow)
        ? [Shadow(color: const Color(0xFF000000), offset: Offset(fs * 0.07, fs * 0.07))]
        : null,
  );
  final tp = TextPainter(
    text: TextSpan(text: l.text, style: style),
    textDirection: TextDirection.ltr,
    textAlign: TextAlign.center,
  );
  tp.layout();
  return tp;
}

Rect _layerRect(EditLayer l, Size size) {
  final c = Offset(l.x * size.width, l.y * size.height);
  if (l.image != null) {
    final w = l.scale * size.width;
    final h = w * l.image!.height / l.image!.width;
    return Rect.fromCenter(center: c, width: w, height: h);
  }
  final tp = _textPainter(l, size.width);
  return Rect.fromCenter(center: c, width: tp.width, height: tp.height);
}

void _paintLayer(Canvas canvas, Size size, EditLayer l) {
  final c = Offset(l.x * size.width, l.y * size.height);
  final img = l.image;
  if (img != null) {
    final r = _layerRect(l, size);
    canvas.drawImageRect(
      img,
      Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
      r,
      Paint()..filterQuality = FilterQuality.high,
    );
  } else {
    if (l.text.isEmpty) return;
    final fill = _textPainter(l, size.width);
    final off = c - Offset(fill.width / 2, fill.height / 2);
    if (l.outline) {
      _textPainter(l, size.width, stroke: true).paint(canvas, off);
    }
    fill.paint(canvas, off);
  }
}

void _drawStroke(Canvas canvas, PenStroke s, bool clear) {
  final p = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..strokeWidth = s.width
    ..isAntiAlias = true;
  if (clear) {
    p.blendMode = BlendMode.clear;
  } else {
    p.color = s.color;
  }
  final path = Path()..moveTo(s.pts.first.dx, s.pts.first.dy);
  if (s.pts.length == 1) {
    path.lineTo(s.pts.first.dx + 0.01, s.pts.first.dy);
  }
  for (var i = 1; i < s.pts.length; i++) {
    path.lineTo(s.pts[i].dx, s.pts[i].dy);
  }
  canvas.drawPath(path, p);
}

void _drawChecker(Canvas canvas, Size size) {
  const t = 14.0;
  final a = Paint()..color = const Color(0xFF1C0606);
  final b = Paint()..color = const Color(0xFF2E0B0B);
  canvas.drawRect(Offset.zero & size, a);
  for (var y = 0; y * t < size.height; y++) {
    for (var x = 0; x * t < size.width; x++) {
      if ((x + y) % 2 == 0) {
        canvas.drawRect(Rect.fromLTWH(x * t, y * t, t, t), b);
      }
    }
  }
}

// Önizleme ve kaydetme aynı fonksiyonla çizilir
void paintScene(
  Canvas canvas,
  Size size,
  ui.Image img,
  List<EditLayer> layers,
  List<double>? matrix, {
  PenStroke? stroke,
  int? selId,
  bool checker = false,
}) {
  final rect = Offset.zero & size;
  final k = size.width / img.width;
  canvas.save();
  canvas.clipRect(rect);
  if (checker) _drawChecker(canvas, size);
  final filterPaint = Paint();
  if (matrix != null) filterPaint.colorFilter = ColorFilter.matrix(matrix);
  canvas.saveLayer(rect, filterPaint);
  canvas.saveLayer(rect, Paint());
  canvas.drawImageRect(
    img,
    Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
    rect,
    Paint()..filterQuality = FilterQuality.high,
  );
  if (stroke != null && stroke.erase) {
    canvas.save();
    canvas.scale(k, k);
    _drawStroke(canvas, stroke, true);
    canvas.restore();
  }
  canvas.restore();
  if (stroke != null && !stroke.erase) {
    canvas.save();
    canvas.scale(k, k);
    _drawStroke(canvas, stroke, false);
    canvas.restore();
  }
  for (final l in layers) {
    _paintLayer(canvas, size, l);
  }
  canvas.restore();
  if (selId != null) {
    for (final l in layers) {
      if (l.id == selId) {
        final r = _layerRect(l, size).inflate(6);
        canvas.drawRect(
          r,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4
            ..color = const Color(0xFF000000),
        );
        canvas.drawRect(
          r,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = kRed,
        );
      }
    }
  }
  canvas.restore();
}

class _ScenePainter extends CustomPainter {
  final ui.Image img;
  final List<EditLayer> layers;
  final List<double> matrix;
  final PenStroke? stroke;
  final int? selId;
  _ScenePainter(this.img, this.layers, this.matrix, this.stroke, this.selId);
  @override
  void paint(Canvas canvas, Size size) {
    paintScene(canvas, size, img, layers, matrix,
        stroke: stroke, selId: selId, checker: true);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _CropPainter extends CustomPainter {
  final Rect r;
  _CropPainter(this.r);
  @override
  void paint(Canvas canvas, Size size) {
    final dim = Paint()..color = const Color(0xAA000000);
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, r.top), dim);
    canvas.drawRect(Rect.fromLTRB(0, r.bottom, size.width, size.height), dim);
    canvas.drawRect(Rect.fromLTRB(0, r.top, r.left, r.bottom), dim);
    canvas.drawRect(Rect.fromLTRB(r.right, r.top, size.width, r.bottom), dim);
    canvas.drawRect(
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = kRed,
    );
    final fill = Paint()..color = kRed;
    for (final p in [r.topLeft, r.topRight, r.bottomLeft, r.bottomRight]) {
      canvas.drawRect(Rect.fromCenter(center: p, width: 20, height: 20), fill);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

Future<ui.Image> _decode(Uint8List bytes, int maxSide) async {
  final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
  final desc = await ui.ImageDescriptor.encoded(buffer);
  int? tw;
  int? th;
  if (desc.width >= desc.height) {
    if (desc.width > maxSide) tw = maxSide;
  } else {
    if (desc.height > maxSide) th = maxSide;
  }
  final codec = await desc.instantiateCodec(targetWidth: tw, targetHeight: th);
  final frame = await codec.getNextFrame();
  return frame.image;
}

class PhotoEditor extends StatefulWidget {
  final File file;
  const PhotoEditor({super.key, required this.file});
  @override
  State<PhotoEditor> createState() => _PhotoEditorState();
}

class _PhotoEditorState extends State<PhotoEditor> {
  ui.Image? _img;
  List<EditLayer> _layers = [];
  double _b = 0;
  double _c = 0;
  double _s = 0;
  int _filter = 0;
  final List<_Snap> _undo = [];
  String _tool = '';
  int? _selId;
  int _nextId = 1;
  bool _saving = false;
  Size _dsz = Size.zero;
  PenStroke? _stroke;
  double _brushSize = 0.03;
  Color _brushColor = kRed;
  Rect _cropN = const Rect.fromLTRB(0.08, 0.08, 0.92, 0.92);
  int _cropMode = -1;
  double _baseScale = 1;
  bool _gestureLayer = false;
  double _rw = 100;
  double _rh = 100;
  bool _keep = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final bytes = await widget.file.readAsBytes();
    final img = await _decode(bytes, 1920);
    if (!mounted) return;
    setState(() => _img = img);
  }

  void _pushUndo() {
    _undo.add(_Snap(_img!, List<EditLayer>.of(_layers), _b, _c, _s, _filter));
    if (_undo.length > 8) _undo.removeAt(0);
  }

  void _undoLast() {
    if (_undo.isEmpty) return;
    final s = _undo.removeLast();
    setState(() {
      _img = s.img;
      _layers = s.layers;
      _b = s.b;
      _c = s.c;
      _s = s.s;
      _filter = s.filter;
      _selId = null;
      _stroke = null;
    });
  }

  // ----- görüntü işleme -----

  ui.Image _renderFlat() {
    final img = _img!;
    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec);
    paintScene(
      canvas,
      Size(img.width.toDouble(), img.height.toDouble()),
      img,
      _layers,
      null,
    );
    return rec.endRecording().toImageSync(img.width, img.height);
  }

  ui.Image _transform(ui.Image src,
      {int turns = 0, bool fx = false, bool fy = false, Rect? crop}) {
    final paint = Paint()..filterQuality = FilterQuality.high;
    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec);
    if (crop != null) {
      final cw = math.max(1, math.min(src.width, crop.width.round()));
      final ch = math.max(1, math.min(src.height, crop.height.round()));
      canvas.drawImageRect(
        src,
        crop,
        Rect.fromLTWH(0, 0, cw.toDouble(), ch.toDouble()),
        paint,
      );
      return rec.endRecording().toImageSync(cw, ch);
    }
    final rot = turns % 4;
    final swap = rot.isOdd;
    final w = swap ? src.height : src.width;
    final h = swap ? src.width : src.height;
    canvas.translate(w / 2, h / 2);
    canvas.scale(fx ? -1.0 : 1.0, fy ? -1.0 : 1.0);
    canvas.rotate(rot * math.pi / 2);
    canvas.translate(-src.width / 2, -src.height / 2);
    canvas.drawImage(src, Offset.zero, paint);
    return rec.endRecording().toImageSync(w, h);
  }

  void _geom({int turns = 0, bool fx = false, bool fy = false, Rect? crop}) {
    _pushUndo();
    final flat = _renderFlat();
    final out = _transform(flat, turns: turns, fx: fx, fy: fy, crop: crop);
    setState(() {
      _img = out;
      _layers = [];
      _selId = null;
    });
  }

  Future<Uint8List> _renderFinal() async {
    final img = _img!;
    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec);
    paintScene(
      canvas,
      Size(img.width.toDouble(), img.height.toDouble()),
      img,
      _layers,
      _buildMatrix(_b, _c, _s, _filter),
    );
    final out = await rec.endRecording().toImage(img.width, img.height);
    final data = await out.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  Future<void> _save() async {
    if (_saving || _img == null) return;
    setState(() {
      _saving = true;
      _selId = null;
    });
    try {
      final bytes = await _renderFinal();
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

  // ----- araçlar -----

  void _setTool(String t) {
    setState(() {
      _tool = _tool == t ? '' : t;
      if (_tool == 'crop') {
        _cropN = const Rect.fromLTRB(0.08, 0.08, 0.92, 0.92);
      }
      if (_tool == 'boyut') {
        _rw = 100;
        _rh = 100;
      }
      if (_tool == 'crop' || _tool == 'brush' || _tool == 'eraser' || _tool == 'boyut') {
        _selId = null;
      }
    });
  }

  void _applyCrop() {
    final img = _img!;
    final src = Rect.fromLTRB(
      _cropN.left * img.width,
      _cropN.top * img.height,
      _cropN.right * img.width,
      _cropN.bottom * img.height,
    );
    _geom(crop: src);
    setState(() => _tool = '');
  }

  Future<String?> _askText(String initial) {
    final ctrl = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: kPanel,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: kRed, width: 3),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Yazı',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: kRed, fontSize: 24)),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                autofocus: true,
                minLines: 1,
                maxLines: 3,
                cursorColor: kRed,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: const InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: kRed, width: 2),
                    borderRadius: BorderRadius.zero,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: kRed, width: 3),
                    borderRadius: BorderRadius.zero,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: PixelButton(
                      label: 'İptal',
                      filled: false,
                      fontSize: 16,
                      onTap: () => Navigator.pop(ctx),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: PixelButton(
                      label: 'Tamam',
                      fontSize: 16,
                      onTap: () => Navigator.pop(ctx, ctrl.text),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addText() async {
    final t = await _askText('');
    if (t == null || t.trim().isEmpty || !mounted) return;
    _pushUndo();
    final l = EditLayer(
      id: _nextId++,
      text: t.trim(),
      x: 0.5,
      y: 0.5,
      scale: 0.08,
    );
    setState(() {
      _layers = [..._layers, l];
      _selId = l.id;
      _tool = '';
    });
  }

  Future<void> _editText() async {
    final id = _selId;
    if (id == null) return;
    final cur = _layers.firstWhere((l) => l.id == id);
    final t = await _askText(cur.text);
    if (t == null || t.trim().isEmpty || !mounted) return;
    _pushUndo();
    setState(() {
      _layers = _layers
          .map((l) => l.id == id ? l.copyWith(text: t.trim()) : l)
          .toList();
    });
  }

  Future<void> _addSticker() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (x == null) return;
    final bytes = await File(x.path).readAsBytes();
    final img = await _decode(bytes, 800);
    if (!mounted) return;
    _pushUndo();
    final l = EditLayer(id: _nextId++, image: img, x: 0.5, y: 0.5, scale: 0.35);
    setState(() {
      _layers = [..._layers, l];
      _selId = l.id;
      _tool = '';
    });
  }

  void _setSel({Color? color, bool? shadow, bool? outline, double? scale}) {
    _layers = _layers
        .map((l) => l.id == _selId
            ? l.copyWith(
                color: color, shadow: shadow, outline: outline, scale: scale)
            : l)
        .toList();
  }

  void _deleteSel() {
    _pushUndo();
    setState(() {
      _layers = _layers.where((l) => l.id != _selId).toList();
      _selId = null;
    });
  }

  // ----- dokunma / sürükleme -----

  int? _hitLayer(Offset p, Size dsz) {
    for (var i = _layers.length - 1; i >= 0; i--) {
      final r = _layerRect(_layers[i], dsz).inflate(14);
      if (r.contains(p)) return _layers[i].id;
    }
    return null;
  }

  void _gStart(ScaleStartDetails d, Size dsz) {
    final p = d.localFocalPoint;
    if (_tool == 'brush' || _tool == 'eraser') {
      final k = _img!.width / dsz.width;
      setState(() {
        _stroke = PenStroke(
          _tool == 'eraser',
          _brushSize * _img!.width,
          _brushColor,
          [p * k],
        );
      });
      return;
    }
    final hit = _hitLayer(p, dsz);
    _gestureLayer = hit != null;
    if (hit != null) {
      _pushUndo();
      _baseScale = _layers.firstWhere((l) => l.id == hit).scale;
    }
    setState(() => _selId = hit);
  }

  void _gUpdate(ScaleUpdateDetails d, Size dsz) {
    if (_stroke != null) {
      final k = _img!.width / dsz.width;
      setState(() => _stroke!.pts.add(d.localFocalPoint * k));
      return;
    }
    if (!_gestureLayer || _selId == null) return;
    setState(() {
      _layers = _layers.map((l) {
        if (l.id != _selId) return l;
        return l.copyWith(
          x: l.x + d.focalPointDelta.dx / dsz.width,
          y: l.y + d.focalPointDelta.dy / dsz.height,
          scale: _cl(_baseScale * d.scale, 0.02, 1.5),
        );
      }).toList();
    });
  }

  void _gEnd(ScaleEndDetails d) {
    final s = _stroke;
    if (s != null) {
      _pushUndo();
      final img = _img!;
      final rec = ui.PictureRecorder();
      final canvas = Canvas(rec);
      final rect =
          Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble());
      canvas.saveLayer(rect, Paint());
      canvas.drawImage(img, Offset.zero, Paint());
      _drawStroke(canvas, s, s.erase);
      canvas.restore();
      final out = rec.endRecording().toImageSync(img.width, img.height);
      setState(() {
        _img = out;
        _stroke = null;
      });
    }
    _gestureLayer = false;
  }

  void _cropStart(Offset p, Size dsz) {
    final c = Rect.fromLTRB(
      _cropN.left * dsz.width,
      _cropN.top * dsz.height,
      _cropN.right * dsz.width,
      _cropN.bottom * dsz.height,
    );
    const r = 40.0;
    if ((p - c.topLeft).distance < r) {
      _cropMode = 1;
    } else if ((p - c.topRight).distance < r) {
      _cropMode = 2;
    } else if ((p - c.bottomLeft).distance < r) {
      _cropMode = 3;
    } else if ((p - c.bottomRight).distance < r) {
      _cropMode = 4;
    } else if (c.contains(p)) {
      _cropMode = 0;
    } else {
      _cropMode = -1;
    }
  }

  void _cropUpdate(Offset d, Size dsz) {
    final dx = d.dx / dsz.width;
    final dy = d.dy / dsz.height;
    final mw = 48 / dsz.width;
    final mh = 48 / dsz.height;
    var c = _cropN;
    switch (_cropMode) {
      case 0:
        {
          final w = c.width;
          final h = c.height;
          final l = _cl(c.left + dx, 0, 1 - w);
          final t = _cl(c.top + dy, 0, 1 - h);
          c = Rect.fromLTWH(l, t, w, h);
          break;
        }
      case 1:
        c = Rect.fromLTRB(
          _cl(c.left + dx, 0, c.right - mw),
          _cl(c.top + dy, 0, c.bottom - mh),
          c.right,
          c.bottom,
        );
        break;
      case 2:
        c = Rect.fromLTRB(
          c.left,
          _cl(c.top + dy, 0, c.bottom - mh),
          _cl(c.right + dx, c.left + mw, 1),
          c.bottom,
        );
        break;
      case 3:
        c = Rect.fromLTRB(
          _cl(c.left + dx, 0, c.right - mw),
          c.top,
          c.right,
          _cl(c.bottom + dy, c.top + mh, 1),
        );
        break;
      case 4:
        c = Rect.fromLTRB(
          c.left,
          c.top,
          _cl(c.right + dx, c.left + mw, 1),
          _cl(c.bottom + dy, c.top + mh, 1),
        );
        break;
      default:
        return;
    }
    setState(() => _cropN = c);
  }

  // ----- arayüz -----

  Widget _scene() {
    final img = _img!;
    return LayoutBuilder(builder: (ctx, cons) {
      final a = img.width / img.height;
      var w = cons.maxWidth;
      var h = w / a;
      if (h > cons.maxHeight) {
        h = cons.maxHeight;
        w = h * a;
      }
      final dsz = Size(w, h);
      _dsz = dsz;
      final matrix = _buildMatrix(_b, _c, _s, _filter);
      final crop = _tool == 'crop';
      return Center(
        child: SizedBox(
          width: w,
          height: h,
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onScaleStart: crop ? null : (d) => _gStart(d, dsz),
                  onScaleUpdate: crop ? null : (d) => _gUpdate(d, dsz),
                  onScaleEnd: crop ? null : (d) => _gEnd(d),
                  child: CustomPaint(
                    painter: _ScenePainter(img, _layers, matrix, _stroke, _selId),
                  ),
                ),
              ),
              if (crop)
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanStart: (d) => _cropStart(d.localPosition, dsz),
                    onPanUpdate: (d) => _cropUpdate(d.delta, dsz),
                    child: CustomPaint(
                      painter: _CropPainter(Rect.fromLTRB(
                        _cropN.left * w,
                        _cropN.top * h,
                        _cropN.right * w,
                        _cropN.bottom * h,
                      )),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final ready = _img != null;
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
                  IconTap(icon: Ico.save, onTap: ready ? _save : null),
                ],
              ),
            ),
            if (_saving)
              const LinearProgressIndicator(color: kRed, backgroundColor: kDarkRed),
            Expanded(
              child: ready
                  ? Padding(padding: const EdgeInsets.all(8), child: _scene())
                  : const Center(child: CircularProgressIndicator(color: kRed)),
            ),
            if (ready) _panelWidget(),
            _toolBar(),
          ],
        ),
      ),
    );
  }

  Widget _panelWidget() {
    switch (_tool) {
      case 'ayar':
        return _adjustPanel();
      case 'filtre':
        return _filterPanel();
      case 'crop':
        return _cropPanel();
      case 'brush':
        return _brushPanel(true);
      case 'eraser':
        return _brushPanel(false);
      case 'boyut':
        return _resizePanel();
    }
    if (_selId != null && _layers.any((l) => l.id == _selId)) {
      return _layerPanel();
    }
    return const SizedBox.shrink();
  }

  Widget _chip(String label, bool on, VoidCallback onTap, {List<String>? icon}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: on ? kRed : Colors.transparent,
          border: Border.all(color: kRed, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              PixelIcon(icon, size: 16, color: on ? Colors.white : kRed),
              const SizedBox(width: 6),
            ],
            Text(label,
                style: TextStyle(color: on ? Colors.white : kRed, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _palette(Color current, void Function(Color) onPick) {
    return SizedBox(
      height: 38,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (final c in kPalette)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onPick(c),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: c,
                  border: Border.all(
                    color: c == current ? Colors.white : kDarkRed,
                    width: c == current ? 3 : 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _slider(String label, double value, double min, double max,
      void Function(double) apply,
      {bool undoOnStart = true}) {
    return Row(
      children: [
        SizedBox(
          width: 104,
          child: Text(label, style: const TextStyle(color: kRed, fontSize: 13)),
        ),
        Expanded(
          child: Slider(
            value: _cl(value, min, max),
            min: min,
            max: max,
            onChangeStart: (_) {
              if (undoOnStart) _pushUndo();
            },
            onChanged: (v) => setState(() => apply(v)),
          ),
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
          _slider('Parlaklık', _b, -100, 100, (v) => _b = v),
          _slider('Kontrast', _c, -100, 100, (v) => _c = v),
          _slider('Doygunluk', _s, -100, 100, (v) => _s = v),
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
          final sel = _filter == i;
          return GestureDetector(
            onTap: () {
              if (!sel) {
                _pushUndo();
                setState(() => _filter = i);
              }
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

  void _applyResize() {
    final img = _img!;
    var nw = img.width * _rw / 100;
    var nh = img.height * _rh / 100;
    final m = math.max(nw, nh);
    if (m > 4096) {
      nw = nw * 4096 / m;
      nh = nh * 4096 / m;
    }
    final w = math.max(2, nw.round());
    final h = math.max(2, nh.round());
    _pushUndo();
    final flat = _renderFlat();
    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec);
    canvas.drawImageRect(
      flat,
      Rect.fromLTWH(0, 0, flat.width.toDouble(), flat.height.toDouble()),
      Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()),
      Paint()..filterQuality = FilterQuality.high,
    );
    final out = rec.endRecording().toImageSync(w, h);
    setState(() {
      _img = out;
      _layers = [];
      _selId = null;
      _tool = '';
      _rw = 100;
      _rh = 100;
    });
  }

  Widget _resizePanel() {
    final img = _img!;
    final nw = (img.width * _rw / 100).round();
    final nh = (img.height * _rh / 100).round();
    return Container(
      color: kPanel,
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _slider('Genişlik', _rw, 10, 300, (v) {
            _rw = v;
            if (_keep) _rh = v;
          }, undoOnStart: false),
          _slider('Yükseklik', _rh, 10, 300, (v) {
            _rh = v;
            if (_keep) _rw = v;
          }, undoOnStart: false),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('$nw x $nh px',
                  style: const TextStyle(color: Colors.white, fontSize: 13)),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              runSpacing: 6,
              children: [
                _chip('Oranı Koru', _keep, () => setState(() => _keep = !_keep)),
                _chip('Sıfırla', false, () {
                  setState(() {
                    _rw = 100;
                    _rh = 100;
                  });
                }),
                _chip('Uygula', false, _applyResize, icon: Ico.resize),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cropPanel() {
    return Container(
      color: kPanel,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: PixelButton(
              label: 'Vazgeç',
              filled: false,
              fontSize: 16,
              onTap: () => setState(() => _tool = ''),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: PixelButton(
              label: 'Kırp',
              icon: Ico.crop,
              fontSize: 16,
              onTap: _applyCrop,
            ),
          ),
        ],
      ),
    );
  }

  Widget _brushPanel(bool withColor) {
    return Container(
      color: kPanel,
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (withColor)
            _palette(_brushColor, (c) => setState(() => _brushColor = c)),
          _slider(withColor ? 'Fırça Boyu' : 'Silgi Boyu', _brushSize, 0.005, 0.12,
              (v) => _brushSize = v,
              undoOnStart: false),
        ],
      ),
    );
  }

  Widget _layerPanel() {
    final l = _layers.firstWhere((e) => e.id == _selId);
    final isText = l.image == null;
    return Container(
      color: kPanel,
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isText)
            _palette(l.color, (c) {
              _pushUndo();
              setState(() => _setSel(color: c));
            }),
          _slider('Boyut', l.scale, 0.02, isText ? 0.4 : 1.0,
              (v) => _setSel(scale: v)),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              runSpacing: 6,
              children: [
                if (isText) _chip('Düzenle', false, _editText, icon: Ico.text),
                if (isText)
                  _chip('Gölge', l.shadow, () {
                    _pushUndo();
                    setState(() => _setSel(shadow: !l.shadow));
                  }),
                if (isText)
                  _chip('Kenar', l.outline, () {
                    _pushUndo();
                    setState(() => _setSel(outline: !l.outline));
                  }),
                _chip('Sil', false, _deleteSel, icon: Ico.trash),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _toolBtn(List<String> icon, String label, bool selected, VoidCallback onTap,
      {bool turned = false}) {
    final fg = selected ? Colors.white : kRed;
    Widget ic = PixelIcon(icon, color: fg, size: 26);
    if (turned) ic = RotatedBox(quarterTurns: 1, child: ic);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 74,
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
    );
  }

  Widget _toolBar() {
    final ready = _img != null;
    void run(VoidCallback f) {
      if (ready) f();
    }

    return Container(
      color: kPanel,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _toolBtn(Ico.rotate, 'Döndür', false, () => run(() => _geom(turns: 1))),
            _toolBtn(Ico.flip, 'Aynala', false, () => run(() => _geom(fx: true))),
            _toolBtn(Ico.flip, 'Ters', false, () => run(() => _geom(fy: true)),
                turned: true),
            _toolBtn(Ico.crop, 'Kırp', _tool == 'crop', () => run(() => _setTool('crop'))),
            _toolBtn(Ico.resize, 'Boyut', _tool == 'boyut', () => run(() => _setTool('boyut'))),
            _toolBtn(Ico.adjust, 'Ayar', _tool == 'ayar', () => run(() => _setTool('ayar'))),
            _toolBtn(Ico.filter, 'Filtre', _tool == 'filtre',
                () => run(() => _setTool('filtre'))),
            _toolBtn(Ico.text, 'Yazı', false, () => run(_addText)),
            _toolBtn(Ico.photo, 'Çıkartma', false, () => run(_addSticker)),
            _toolBtn(Ico.brush, 'Çiz', _tool == 'brush', () => run(() => _setTool('brush'))),
            _toolBtn(Ico.eraser, 'Silgi', _tool == 'eraser',
                () => run(() => _setTool('eraser'))),
          ],
        ),
      ),
    );
  }
}
