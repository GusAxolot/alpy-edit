import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'main.dart';

double _d(dynamic v) => (v as num).toDouble();
int _i(dynamic v) => (v as num).toInt();
double _c(double v, double lo, double hi) => v < lo ? lo : (v > hi ? hi : v);
String _two(int n) => n.toString().padLeft(2, '0');

String _fmt(int ms) {
  final s = ms ~/ 1000;
  return '${s ~/ 60}:${_two(s % 60)}';
}

// ---------- Piksel ikonlar (video) ----------

class VIco {
  static const List<String> play = [
    "...........",
    "..##.......",
    "..####.....",
    "..######...",
    "..########.",
    "..#########",
    "..########.",
    "..######...",
    "..####.....",
    "..##.......",
    "...........",
  ];
  static const List<String> pause = [
    "...........",
    ".###...###.",
    ".###...###.",
    ".###...###.",
    ".###...###.",
    ".###...###.",
    ".###...###.",
    ".###...###.",
    ".###...###.",
    ".###...###.",
    "...........",
  ];
  static const List<String> split = [
    ".....#.....",
    ".....#.....",
    "####.#.####",
    "####.#.####",
    "####.#.####",
    "####.#.####",
    "####.#.####",
    ".....#.....",
    ".....#.....",
    "...........",
    "...........",
  ];
  static const List<String> music = [
    "....#######",
    "....#.....#",
    "....#.....#",
    "....#.....#",
    "....#.....#",
    "..###...###",
    ".####..####",
    ".####..####",
    "..##....##.",
    "...........",
    "...........",
  ];
  static const List<String> export = [
    ".....#.....",
    ".....#.....",
    ".....#.....",
    "..#..#..#..",
    "...#####...",
    "....###....",
    ".....#.....",
    "#.........#",
    "#.........#",
    "###########",
    "...........",
  ];
}

// ---------- Proje modeli ----------

class VClip {
  String path;
  int srcMs;
  double vw;
  double vh;
  int startMs;
  int endMs;
  double speed;
  double volume;
  double sx;
  double sy;
  double cl;
  double ct;
  double cr;
  double cb;
  int inA;
  int outA;
  int animMs;
  bool chroma;
  String bg;
  int rot;
  bool flipH;
  bool flipV;
  int filter;
  int fadeMs;
  VClip({
    required this.path,
    required this.srcMs,
    required this.vw,
    required this.vh,
    required this.startMs,
    required this.endMs,
    this.speed = 1,
    this.volume = 1,
    this.sx = 1,
    this.sy = 1,
    this.cl = 0,
    this.ct = 0,
    this.cr = 1,
    this.cb = 1,
    this.inA = 0,
    this.outA = 0,
    this.animMs = 500,
    this.chroma = false,
    this.bg = '',
    this.rot = 0,
    this.flipH = false,
    this.flipV = false,
    this.filter = 0,
    this.fadeMs = 0,
  });
  double get rw => rot.isOdd ? vh : vw;
  double get rh => rot.isOdd ? vw : vh;
  int get durMs => math.max(1, ((endMs - startMs) / speed).round());
  Map<String, dynamic> toJson() => {
        'path': path,
        'srcMs': srcMs,
        'vw': vw,
        'vh': vh,
        'startMs': startMs,
        'endMs': endMs,
        'speed': speed,
        'volume': volume,
        'sx': sx,
        'sy': sy,
        'cl': cl,
        'ct': ct,
        'cr': cr,
        'cb': cb,
        'inA': inA,
        'outA': outA,
        'animMs': animMs,
        'chroma': chroma,
        'bg': bg,
        'rot': rot,
        'flipH': flipH,
        'flipV': flipV,
        'filter': filter,
        'fadeMs': fadeMs,
      };
  factory VClip.fromJson(Map<String, dynamic> j) => VClip(
        path: j['path'] as String,
        srcMs: _i(j['srcMs']),
        vw: _d(j['vw']),
        vh: _d(j['vh']),
        startMs: _i(j['startMs']),
        endMs: _i(j['endMs']),
        speed: _d(j['speed'] ?? 1),
        volume: _d(j['volume'] ?? 1),
        sx: _d(j['sx'] ?? 1),
        sy: _d(j['sy'] ?? 1),
        cl: _d(j['cl'] ?? 0),
        ct: _d(j['ct'] ?? 0),
        cr: _d(j['cr'] ?? 1),
        cb: _d(j['cb'] ?? 1),
        inA: _i(j['inA'] ?? 0),
        outA: _i(j['outA'] ?? 0),
        animMs: _i(j['animMs'] ?? 500),
        chroma: (j['chroma'] ?? false) as bool,
        bg: (j['bg'] ?? '') as String,
        rot: _i(j['rot'] ?? 0),
        flipH: (j['flipH'] ?? false) as bool,
        flipV: (j['flipV'] ?? false) as bool,
        filter: _i(j['filter'] ?? 0),
        fadeMs: _i(j['fadeMs'] ?? 0),
      );
}

class TClip {
  int id;
  String text;
  int startMs;
  int durMs;
  double x;
  double y;
  double size;
  int color;
  bool shadow;
  bool outline;
  int inA;
  int outA;
  int animMs;
  TClip({
    required this.id,
    required this.text,
    required this.startMs,
    this.durMs = 3000,
    this.x = 0.5,
    this.y = 0.5,
    this.size = 0.07,
    this.color = 0xFFFFFFFF,
    this.shadow = true,
    this.outline = true,
    this.inA = 1,
    this.outA = 1,
    this.animMs = 400,
  });
  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'startMs': startMs,
        'durMs': durMs,
        'x': x,
        'y': y,
        'size': size,
        'color': color,
        'shadow': shadow,
        'outline': outline,
        'inA': inA,
        'outA': outA,
        'animMs': animMs,
      };
  factory TClip.fromJson(Map<String, dynamic> j) => TClip(
        id: _i(j['id']),
        text: j['text'] as String,
        startMs: _i(j['startMs']),
        durMs: _i(j['durMs']),
        x: _d(j['x']),
        y: _d(j['y']),
        size: _d(j['size']),
        color: _i(j['color']),
        shadow: j['shadow'] as bool,
        outline: j['outline'] as bool,
        inA: _i(j['inA']),
        outA: _i(j['outA']),
        animMs: _i(j['animMs']),
      );
}

class AClip {
  int id;
  String path;
  String name;
  int srcMs;
  int startMs;
  double volume;
  int fadeInMs;
  int fadeOutMs;
  AClip({
    required this.id,
    required this.path,
    required this.name,
    required this.srcMs,
    required this.startMs,
    this.volume = 1,
    this.fadeInMs = 0,
    this.fadeOutMs = 0,
  });
  Map<String, dynamic> toJson() => {
        'id': id,
        'path': path,
        'name': name,
        'srcMs': srcMs,
        'startMs': startMs,
        'volume': volume,
        'fadeInMs': fadeInMs,
        'fadeOutMs': fadeOutMs,
      };
  factory AClip.fromJson(Map<String, dynamic> j) => AClip(
        id: _i(j['id']),
        path: j['path'] as String,
        name: j['name'] as String,
        srcMs: _i(j['srcMs']),
        startMs: _i(j['startMs']),
        volume: _d(j['volume']),
        fadeInMs: _i(j['fadeInMs'] ?? 0),
        fadeOutMs: _i(j['fadeOutMs'] ?? 0),
      );
}

class Project {
  String id;
  String name;
  int aspect; // 0: 9:16, 1: 16:9, 2: 1:1
  List<VClip> clips;
  List<TClip> texts;
  List<AClip> audios;
  int nextId;
  Project({
    required this.id,
    required this.name,
    required this.aspect,
    List<VClip>? clips,
    List<TClip>? texts,
    List<AClip>? audios,
    this.nextId = 1,
  })  : clips = clips ?? [],
        texts = texts ?? [],
        audios = audios ?? [];
  int get totalMs => clips.fold(0, (a, c) => a + c.durMs);
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'aspect': aspect,
        'nextId': nextId,
        'clips': clips.map((e) => e.toJson()).toList(),
        'texts': texts.map((e) => e.toJson()).toList(),
        'audios': audios.map((e) => e.toJson()).toList(),
      };
  factory Project.fromJson(Map<String, dynamic> j) => Project(
        id: j['id'] as String,
        name: j['name'] as String,
        aspect: _i(j['aspect']),
        nextId: _i(j['nextId']),
        clips: (j['clips'] as List)
            .map((e) => VClip.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        texts: (j['texts'] as List)
            .map((e) => TClip.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        audios: (j['audios'] as List)
            .map((e) => AClip.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}

List<int> canvasSize(int aspect, double sc) {
  int w;
  int h;
  if (aspect == 1) {
    w = 1280;
    h = 720;
  } else if (aspect == 2) {
    w = 720;
    h = 720;
  } else {
    w = 720;
    h = 1280;
  }
  return [(w * sc / 2).round() * 2, (h * sc / 2).round() * 2];
}

// ---------- Dosya işlemleri ----------

Future<Directory> _sub(String name) async {
  final d = await getApplicationDocumentsDirectory();
  final m = Directory('${d.path}/$name');
  if (!await m.exists()) await m.create(recursive: true);
  return m;
}

Future<String> importFile(String src) async {
  final m = await _sub('media');
  final i = src.lastIndexOf('.');
  final ext = i >= 0 && src.length - i <= 6 ? src.substring(i) : '.bin';
  final dest = '${m.path}/${DateTime.now().microsecondsSinceEpoch}$ext';
  await File(src).copy(dest);
  return dest;
}

Future<void> saveProject(Project p) async {
  try {
    final d = await _sub('projects');
    await File('${d.path}/${p.id}.json').writeAsString(jsonEncode(p.toJson()));
  } catch (_) {}
}

Future<List<Project>> listProjects() async {
  final out = <Project>[];
  try {
    final d = await _sub('projects');
    for (final f in d.listSync()) {
      if (f is File && f.path.endsWith('.json')) {
        try {
          final j = jsonDecode(await f.readAsString());
          out.add(Project.fromJson(Map<String, dynamic>.from(j as Map)));
        } catch (_) {}
      }
    }
  } catch (_) {}
  out.sort((a, b) => b.id.compareTo(a.id));
  return out;
}

Future<void> deleteProject(Project p) async {
  try {
    final d = await _sub('projects');
    final f = File('${d.path}/${p.id}.json');
    if (await f.exists()) await f.delete();
    final files = <String>[
      for (final c in p.clips) c.path,
      for (final c in p.clips)
        if (c.bg.isNotEmpty) c.bg,
      for (final a in p.audios) a.path,
    ];
    for (final path in files) {
      try {
        await File(path).delete();
      } catch (_) {}
    }
  } catch (_) {}
}

Future<Project?> createProjectFromVideo(String srcPath) async {
  final path = await importFile(srcPath);
  final c = VideoPlayerController.file(File(path));
  try {
    await c.initialize();
  } catch (_) {
    return null;
  }
  final size = c.value.size;
  final dur = c.value.duration.inMilliseconds;
  await c.dispose();
  final now = DateTime.now();
  final p = Project(
    id: now.millisecondsSinceEpoch.toString(),
    name: 'Proje ${_two(now.day)}.${_two(now.month)} ${_two(now.hour)}:${_two(now.minute)}',
    aspect: size.width >= size.height ? 1 : 0,
  );
  p.clips.add(VClip(
    path: path,
    srcMs: dur,
    vw: size.width,
    vh: size.height,
    startMs: 0,
    endMs: dur,
  ));
  await saveProject(p);
  return p;
}

// ---------- Animasyonlar ----------

const List<String> kAnimNames = [
  'Yok',
  'Belirme',
  'Soldan',
  'Sağdan',
  'Yukarıdan',
  'Aşağıdan',
  'Yakınlaşma',
  'Zıplama',
  'Dönme',
  'Daktilo',
];
const List<int> kClipAnims = [0, 1, 2, 3, 4, 5, 6, 7, 8];
const List<int> kTextAnims = [0, 1, 9, 2, 3, 4, 5, 7];

class Fx {
  final double op;
  final double dx;
  final double dy;
  final double sc;
  final double rot;
  const Fx(this.op, this.dx, this.dy, this.sc, this.rot);
}

double _ease(double p) => 1 - (1 - p) * (1 - p);

Fx _fxOf(int type, double p) {
  switch (type) {
    case 1:
      return Fx(p, 0, 0, 1, 0);
    case 2:
      return Fx(1, -(1 - p), 0, 1, 0);
    case 3:
      return Fx(1, 1 - p, 0, 1, 0);
    case 4:
      return Fx(1, 0, -(1 - p), 1, 0);
    case 5:
      return Fx(1, 0, 1 - p, 1, 0);
    case 6:
      return Fx(1, 0, 0, 0.3 + 0.7 * p, 0);
    case 7:
      return Fx(1, 0, -(1 - p) * 0.3 * math.cos(p * 7.85398).abs(), 1, 0);
    case 8:
      return Fx(1, 0, 0, 1, (1 - p) * 6.28318);
    default:
      return const Fx(1, 0, 0, 1, 0);
  }
}

Fx _fxMerge(Fx a, Fx b) =>
    Fx(a.op * b.op, a.dx + b.dx, a.dy + b.dy, a.sc * b.sc, a.rot + b.rot);

// ---------- Video filtreleri ve geçişler ----------

class VFilter {
  final String name;
  final List<double> matrix;
  final String ff;
  const VFilter(this.name, this.matrix, this.ff);
}

const List<VFilter> kVFilters = [
  VFilter('Normal', [
    1, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 0, 1, 0,
  ], ''),
  VFilter('Siyah Beyaz', [
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0, 0, 0, 1, 0,
  ], 'hue=s=0'),
  VFilter('Sepya', [
    0.393, 0.769, 0.189, 0, 0,
    0.349, 0.686, 0.168, 0, 0,
    0.272, 0.534, 0.131, 0, 0,
    0, 0, 0, 1, 0,
  ], 'colorchannelmixer=.393:.769:.189:0:.349:.686:.168:0:.272:.534:.131:0'),
  VFilter('Kırmızı', [
    1.3, 0.1, 0, 0, 0,
    0, 0.55, 0, 0, 0,
    0, 0, 0.55, 0, 0,
    0, 0, 0, 1, 0,
  ], 'colorchannelmixer=1.3:.1:0:0:0:.55:0:0:0:0:.55:0'),
  VFilter('Soğuk', [
    0.9, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 1.25, 0, 0,
    0, 0, 0, 1, 0,
  ], 'colorchannelmixer=.9:0:0:0:0:1:0:0:0:0:1.25:0'),
  VFilter('Sıcak', [
    1.2, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 0.8, 0, 0,
    0, 0, 0, 1, 0,
  ], 'colorchannelmixer=1.2:0:0:0:0:1:0:0:0:0:.8:0'),
  VFilter('Negatif', [
    -1, 0, 0, 0, 255,
    0, -1, 0, 0, 255,
    0, 0, -1, 0, 255,
    0, 0, 0, 1, 0,
  ], 'negate'),
  VFilter('Gece', [
    0.6, 0, 0, 0, 0,
    0, 0.7, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 0, 1, 0,
  ], 'colorchannelmixer=.6:0:0:0:0:.7:0:0:0:0:1:0'),
];

const List<String> kTransNames = [
  'Yok',
  'Belirme',
  'Sola Kayma',
  'Sağa Kayma',
  'Yukarı Kayma',
  'Aşağı Kayma',
  'Yakınlaşma',
  'Zıplama',
  'Dönme',
];
// [birinci kesitin çıkışı, ikinci kesitin girişi]
const List<List<int>> kTransPairs = [
  [0, 0],
  [1, 1],
  [2, 3],
  [3, 2],
  [4, 5],
  [5, 4],
  [6, 6],
  [7, 7],
  [8, 8],
];

double _fadeMul(int local, int dur, int fin, int fout) {
  var m = 1.0;
  if (fin > 0) m = math.min(m, local / fin);
  if (fout > 0) m = math.min(m, (dur - local) / fout);
  return _c(m, 0, 1);
}

String _afade(int inMs, int outMs, double dur) {
  final sb = StringBuffer();
  final fi = math.min(inMs / 1000.0, dur / 2);
  final fo = math.min(outMs / 1000.0, dur / 2);
  if (inMs > 0) sb.write(',afade=t=in:st=0:d=${_s(fi)}');
  if (outMs > 0) {
    sb.write(',afade=t=out:st=${_s(math.max(0, dur - fo))}:d=${_s(fo)}');
  }
  return sb.toString();
}

// ---------- Dışa aktarma (FFmpeg) ----------

String _s(double v) => v.toStringAsFixed(3);
int _ev(double v) {
  final r = (v / 2).round() * 2;
  return r < 2 ? 2 : r;
}

Future<bool> _hasAudio(String path) async {
  try {
    final dynamic s = await FFprobeKit.getMediaInformation(path);
    final dynamic info = s.getMediaInformation();
    final dynamic streams = info?.getStreams();
    if (streams == null) return true;
    for (final st in streams) {
      if (st.getType() == 'audio') return true;
    }
    return false;
  } catch (_) {
    return true;
  }
}

String _tempoChain(double s) {
  if (s == 1) return '';
  if (s >= 0.5) return ',atempo=${_s(s)}';
  return ',atempo=0.5,atempo=${_s(s / 0.5)}';
}

Future<String> buildExportCommand(
    Project p, double sc, String out, String font, String tmp) async {
  final cs = canvasSize(p.aspect, sc);
  final outW = cs[0];
  final outH = cs[1];
  final inputs = <String>[];
  final fc = <String>[];
  final vTags = StringBuffer();
  final aTags = StringBuffer();
  var total = 0;

  for (var i = 0; i < p.clips.length; i++) {
    final c = p.clips[i];
    final d = c.durMs / 1000.0;
    final a = math.min(c.animMs / 1000.0, d / 2);
    total += c.durMs;
    final vin = inputs.length;
    inputs.add('-i "${c.path}"');

    final cwF = c.cr - c.cl;
    final chF = c.cb - c.ct;
    final srcW = c.rw * cwF;
    final srcH = c.rh * chF;
    final k = math.min(outW / srcW, outH / srcH);
    final ow = _ev(math.min(srcW * k * c.sx, outW * 4.0));
    final oh = _ev(math.min(srcH * k * c.sy, outH * 4.0));
    final pin = '(1-pow(1-min(1,max(0,t/${_s(a)})),2))';
    final pout = '(1-pow(1-min(1,max(0,(${_s(d)}-t)/${_s(a)})),2))';

    final f = StringBuffer(
        '[$vin:v]trim=start=${_s(c.startMs / 1000)}:end=${_s(c.endMs / 1000)},setpts=(PTS-STARTPTS)/${_s(c.speed)}');
    switch (c.rot % 4) {
      case 1:
        f.write(',transpose=1');
        break;
      case 2:
        f.write(',hflip,vflip');
        break;
      case 3:
        f.write(',transpose=2');
        break;
    }
    if (c.flipH) f.write(',hflip');
    if (c.flipV) f.write(',vflip');
    if (c.cl > 0 || c.ct > 0 || c.cr < 1 || c.cb < 1) {
      f.write(
          ',crop=iw*${_s(cwF)}:ih*${_s(chF)}:iw*${_s(c.cl)}:ih*${_s(c.ct)}');
    }
    f.write(',scale=$ow:$oh,setsar=1,fps=30');
    if (c.filter > 0 && c.filter < kVFilters.length) {
      f.write(',${kVFilters[c.filter].ff}');
    }
    final needAlpha = c.chroma ||
        c.inA == 1 ||
        c.outA == 1 ||
        c.inA == 8 ||
        c.outA == 8;
    if (needAlpha) f.write(',format=yuva420p');
    if (c.chroma) {
      f.write(',chromakey=color=0x00FF00:similarity=0.25:blend=0.08');
    }
    if (c.inA == 1) f.write(',fade=t=in:st=0:d=${_s(a)}:alpha=1');
    if (c.outA == 1) {
      f.write(',fade=t=out:st=${_s(math.max(0, d - a))}:d=${_s(a)}:alpha=1');
    }
    if (c.inA == 6 || c.outA == 6) {
      final parts = <String>[];
      if (c.inA == 6) parts.add('(0.3+0.7*$pin)');
      if (c.outA == 6) parts.add('(0.3+0.7*$pout)');
      final fac = parts.join('*');
      f.write(
          ",scale=w='max(2,trunc($ow*$fac/2)*2)':h='max(2,trunc($oh*$fac/2)*2)':eval=frame");
    }
    if (c.inA == 8 || c.outA == 8) {
      final parts = <String>[];
      if (c.inA == 8) parts.add('(1-$pin)*6.28318');
      if (c.outA == 8) parts.add('(1-$pout)*6.28318');
      f.write(
          ",rotate=a='${parts.join('+')}':ow='ceil(hypot(iw,ih)/2)*2':oh='ceil(hypot(iw,ih)/2)*2':c=black@0");
    }
    f.write('[v$i]');
    fc.add(f.toString());

    final xs = <String>['(main_w-overlay_w)/2'];
    final ys = <String>['(main_h-overlay_h)/2'];
    void addPos(int type, String pp) {
      switch (type) {
        case 2:
          xs.add('-(1-$pp)*main_w');
          break;
        case 3:
          xs.add('(1-$pp)*main_w');
          break;
        case 4:
          ys.add('-(1-$pp)*main_h');
          break;
        case 5:
          ys.add('(1-$pp)*main_h');
          break;
        case 7:
          ys.add('-(1-$pp)*0.3*main_h*abs(cos($pp*7.85398))');
          break;
      }
    }

    addPos(c.inA, pin);
    addPos(c.outA, pout);
    final x = xs.join('+');
    final y = ys.join('+');

    if (c.chroma && c.bg.isNotEmpty) {
      final bi = inputs.length;
      inputs.add('-loop 1 -framerate 30 -t ${_s(d)} -i "${c.bg}"');
      fc.add(
          '[$bi:v]scale=$outW:$outH:force_original_aspect_ratio=increase,crop=$outW:$outH,setsar=1,fps=30,format=yuv420p[bg$i]');
    } else {
      fc.add('color=c=black:s=${outW}x$outH:r=30:d=${_s(d)}[bg$i]');
    }
    fc.add(
        "[bg$i][v$i]overlay=x='$x':y='$y':shortest=1,format=yuv420p,setsar=1,fps=30[c$i]");
    vTags.write('[c$i]');

    if (await _hasAudio(c.path)) {
      fc.add(
          '[$vin:a]atrim=start=${_s(c.startMs / 1000)}:end=${_s(c.endMs / 1000)},asetpts=PTS-STARTPTS${_tempoChain(c.speed)},volume=${_s(c.volume)}${_afade(c.fadeMs, c.fadeMs, d)},aformat=sample_rates=44100:channel_layouts=stereo[a$i]');
    } else {
      fc.add(
          'anullsrc=r=44100:cl=stereo:d=${_s(d)},aformat=sample_rates=44100:channel_layouts=stereo[a$i]');
    }
    aTags.write('[a$i]');
  }

  final n = p.clips.length;
  if (n == 1) {
    fc.add('[c0]null[vm]');
    fc.add('[a0]anull[am]');
  } else {
    fc.add('${vTags}concat=n=$n:v=1:a=0[vm]');
    fc.add('${aTags}concat=n=$n:v=0:a=1[am]');
  }

  // yazılar
  final dts = <String>[];
  var fileNo = 0;
  for (final t in p.texts) {
    if (t.text.trim().isEmpty) continue;
    final fs = math.max(8, (t.size * outW).round());
    final bw = t.outline ? math.max(1, (fs * 0.07).round()) : 0;
    final sh = t.shadow ? math.max(1, (fs * 0.07).round()) : 0;
    final s0 = t.startMs / 1000.0;
    final e0 = (t.startMs + t.durMs) / 1000.0;
    final a = math.min(t.animMs / 1000.0, (t.durMs / 1000.0) / 2);
    final pin = '(1-pow(1-min(1,max(0,(t-${_s(s0)})/${_s(a)})),2))';
    final pout = '(1-pow(1-min(1,max(0,(${_s(e0)}-t)/${_s(a)})),2))';
    final xs = <String>['(w*${_s(t.x)})-text_w/2'];
    final ys = <String>['(h*${_s(t.y)})-text_h/2'];
    final alphas = <String>[];
    void addT(int type, String pp) {
      switch (type) {
        case 1:
          alphas.add(pp);
          break;
        case 2:
          xs.add('-(1-$pp)*w');
          break;
        case 3:
          xs.add('(1-$pp)*w');
          break;
        case 4:
          ys.add('-(1-$pp)*h');
          break;
        case 5:
          ys.add('(1-$pp)*h');
          break;
        case 7:
          ys.add('-(1-$pp)*0.3*h*abs(cos($pp*7.85398))');
          break;
      }
    }

    addT(t.inA, pin);
    addT(t.outA, pout);
    final color = (t.color & 0xFFFFFF).toRadixString(16).padLeft(6, '0');
    final alphaPart =
        alphas.isEmpty ? '' : ":alpha='${alphas.join('*')}'";
    String one(String file, String enable) =>
        "drawtext=fontfile='$font':textfile='$file':expansion=none:fontsize=$fs:fontcolor=0x$color:x='${xs.join('+')}':y='${ys.join('+')}':borderw=$bw:bordercolor=black:shadowx=$sh:shadowy=$sh:shadowcolor=black$alphaPart:enable='$enable'";

    if (t.inA == 9) {
      final len = t.text.length;
      final step = math.max(1, (len / 40).ceil());
      final shots = (len / step).ceil();
      final dt = a / shots;
      for (var k = 1; k <= shots; k++) {
        final shown = math.min(len, k * step);
        final file = '$tmp/txt_${fileNo++}.txt';
        await File(file).writeAsString(t.text.substring(0, shown));
        final from = s0 + (k - 1) * dt;
        final to = k == shots ? e0 : s0 + k * dt;
        dts.add(one(file, 'between(t,${_s(from)},${_s(to)})'));
      }
    } else {
      final file = '$tmp/txt_${fileNo++}.txt';
      await File(file).writeAsString(t.text);
      dts.add(one(file, 'between(t,${_s(s0)},${_s(e0)})'));
    }
  }
  if (dts.isEmpty) {
    fc.add('[vm]null[vout]');
  } else {
    fc.add('[vm]${dts.join(',')}[vout]');
  }

  // müzikler
  final mTags = StringBuffer();
  var mCount = 0;
  for (final au in p.audios) {
    final ai = inputs.length;
    inputs.add('-i "${au.path}"');
    final ms = math.max(0, au.startMs);
    fc.add(
        '[$ai:a]atrim=start=0:end=${_s(au.srcMs / 1000)},asetpts=PTS-STARTPTS,volume=${_s(au.volume)}${_afade(au.fadeInMs, au.fadeOutMs, au.srcMs / 1000.0)},adelay=$ms|$ms,aformat=sample_rates=44100:channel_layouts=stereo[m$mCount]');
    mTags.write('[m$mCount]');
    mCount++;
  }
  if (mCount == 0) {
    fc.add('[am]anull[aout]');
  } else {
    fc.add(
        '[am]${mTags}amix=inputs=${mCount + 1}:duration=first:normalize=0:dropout_transition=0[aout]');
  }

  return '-y ${inputs.join(' ')} -filter_complex "${fc.join(';')}" -map "[vout]" -map "[aout]" -t ${_s(total / 1000)} -c:v libx264 -preset veryfast -crf 23 -pix_fmt yuv420p -r 30 -c:a aac -b:a 160k -ar 44100 -movflags +faststart "$out"';
}

// ---------- Önizleme çizimleri ----------

class _VRulerPainter extends CustomPainter {
  final int totalMs;
  final double pxMs;
  _VRulerPainter(this.totalMs, this.pxMs);
  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = kDarkRed
      ..strokeWidth = 1;
    final every = pxMs * 1000 >= 40 ? 1 : 5;
    for (var s = 0; s * 1000 <= totalMs + 2000; s++) {
      final x = s * 1000 * pxMs;
      canvas.drawLine(Offset(x, 10), Offset(x, 20), line);
      if (s % every == 0) {
        final tp = TextPainter(
          text: TextSpan(
            text: '${s}s',
            style: const TextStyle(
                fontFamily: 'Minecraft', fontSize: 10, color: kRed),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x + 2, 0));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _VCropPainter extends CustomPainter {
  final Rect r;
  final Rect bounds;
  _VCropPainter(this.r, this.bounds);
  @override
  void paint(Canvas canvas, Size size) {
    final dim = Paint()..color = const Color(0xAA000000);
    canvas.drawRect(Rect.fromLTRB(bounds.left, bounds.top, bounds.right, r.top), dim);
    canvas.drawRect(Rect.fromLTRB(bounds.left, r.bottom, bounds.right, bounds.bottom), dim);
    canvas.drawRect(Rect.fromLTRB(bounds.left, r.top, r.left, r.bottom), dim);
    canvas.drawRect(Rect.fromLTRB(r.right, r.top, bounds.right, r.bottom), dim);
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

// ---------- Video editörü ----------

class VideoEditor extends StatefulWidget {
  final Project project;
  const VideoEditor({super.key, required this.project});
  @override
  State<VideoEditor> createState() => _VideoEditorState();
}

class _VideoEditorState extends State<VideoEditor> {
  late Project _p;
  final Map<String, Future<VideoPlayerController?>> _futs = {};
  final Map<String, VideoPlayerController> _vc = {};
  final Map<String, Future<VideoPlayerController?>> _afuts = {};
  final Map<String, VideoPlayerController> _ac = {};
  final Set<int> _aOn = {};
  final List<String> _undo = [];

  bool _playing = false;
  int _t = 0;
  Timer? _timer;
  final Stopwatch _sw = Stopwatch();
  int _last = 0;
  int _curIdx = -1;

  String _selKind = '';
  int _selId = -1;
  String _sub = '';

  bool _cropping = false;
  Rect _cropN = const Rect.fromLTRB(0, 0, 1, 1);
  int _cropMode = -1;

  double _pxMs = 0.08;
  final ScrollController _sc = ScrollController();
  double _pw = 1;
  double _ph = 1;
  double _baseSize = 0.07;

  bool _seeking = false;
  int? _pendingSeek;

  bool _exporting = false;
  bool _cancelled = false;
  double _expProgress = 0;
  final StringBuffer _log = StringBuffer();

  @override
  void initState() {
    super.initState();
    _p = widget.project;
    for (final c in _p.clips) {
      _ctrl(c.path);
    }
    for (final a in _p.audios) {
      _ctrlA(a.path);
    }
    _seek(0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _vc.values) {
      c.dispose();
    }
    for (final c in _ac.values) {
      c.dispose();
    }
    _sc.dispose();
    saveProject(_p);
    super.dispose();
  }

  // ----- oynatıcılar -----

  Future<VideoPlayerController?> _ctrl(String path) {
    return _futs.putIfAbsent(path, () async {
      final c = VideoPlayerController.file(File(path));
      try {
        await c.initialize();
      } catch (_) {
        return null;
      }
      _vc[path] = c;
      if (mounted) setState(() {});
      return c;
    });
  }

  Future<VideoPlayerController?> _ctrlA(String path) {
    return _afuts.putIfAbsent(path, () async {
      final c = VideoPlayerController.file(File(path));
      try {
        await c.initialize();
      } catch (_) {
        return null;
      }
      _ac[path] = c;
      return c;
    });
  }

  List<int> _locate(int t) {
    var acc = 0;
    for (var i = 0; i < _p.clips.length; i++) {
      final d = _p.clips[i].durMs;
      if (t < acc + d || i == _p.clips.length - 1) {
        return [i, math.min(math.max(0, t - acc), d)];
      }
      acc += d;
    }
    return [0, 0];
  }

  int _clipStart(int idx) {
    var acc = 0;
    for (var i = 0; i < idx && i < _p.clips.length; i++) {
      acc += _p.clips[i].durMs;
    }
    return acc;
  }

  Future<void> _applyClip(int idx, int local, {required bool play}) async {
    if (idx < 0 || idx >= _p.clips.length) return;
    final c = _p.clips[idx];
    final ctrl = await _ctrl(c.path);
    if (ctrl == null) return;
    for (final e in _vc.entries) {
      if (e.key != c.path) e.value.pause();
    }
    await ctrl.setPlaybackSpeed(c.speed);
    await ctrl.setVolume(_c(c.volume, 0, 1));
    await ctrl.seekTo(Duration(milliseconds: c.startMs + (local * c.speed).round()));
    if (play) {
      await ctrl.play();
    } else {
      await ctrl.pause();
    }
  }

  Future<void> _seek(int t) async {
    _pendingSeek = t;
    if (_seeking) return;
    _seeking = true;
    while (_pendingSeek != null) {
      final tt = _pendingSeek!;
      _pendingSeek = null;
      if (_p.clips.isNotEmpty) {
        final loc = _locate(tt);
        _curIdx = loc[0];
        await _applyClip(loc[0], loc[1], play: false);
      }
    }
    _seeking = false;
  }

  Future<void> _play() async {
    if (_p.clips.isEmpty) return;
    if (_t >= _p.totalMs) _t = 0;
    final loc = _locate(_t);
    _curIdx = loc[0];
    await _applyClip(loc[0], loc[1], play: true);
    _aOn.clear();
    _sw
      ..reset()
      ..start();
    _last = 0;
    _playing = true;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 33), (_) => _onTick());
    if (mounted) setState(() {});
  }

  void _pause() {
    _playing = false;
    _timer?.cancel();
    _sw.stop();
    for (final c in _vc.values) {
      c.pause();
    }
    for (final c in _ac.values) {
      c.pause();
    }
    _aOn.clear();
    if (mounted) setState(() {});
  }

  void _togglePlay() {
    if (_playing) {
      _pause();
    } else {
      _play();
    }
  }

  void _onTick() {
    if (!_playing) return;
    final now = _sw.elapsedMilliseconds;
    final dt = now - _last;
    _last = now;
    final nt = _t + dt;
    final total = _p.totalMs;
    if (nt >= total) {
      _t = total;
      _pause();
      return;
    }
    _t = nt;
    final loc = _locate(_t);
    if (loc[0] != _curIdx) {
      _curIdx = loc[0];
      _applyClip(loc[0], loc[1], play: true);
    }
    if (_p.clips.isNotEmpty) {
      final cc = _p.clips[loc[0]];
      _vc[cc.path]?.setVolume(_c(
          cc.volume * _fadeMul(loc[1], cc.durMs, cc.fadeMs, cc.fadeMs), 0, 1));
    }
    _syncAudio();
    setState(() {});
    _autoScroll();
  }

  void _syncAudio() {
    for (final a in _p.audios) {
      final ctrl = _ac[a.path];
      if (ctrl == null) continue;
      final inRange = _t >= a.startMs && _t < a.startMs + a.srcMs;
      if (_playing && inRange) {
        final vol = _c(
            a.volume *
                _fadeMul(_t - a.startMs, a.srcMs, a.fadeInMs, a.fadeOutMs),
            0,
            1);
        if (!_aOn.contains(a.id)) {
          _aOn.add(a.id);
          ctrl.setVolume(vol);
          ctrl.seekTo(Duration(milliseconds: _t - a.startMs));
          ctrl.play();
        } else {
          ctrl.setVolume(vol);
        }
      } else if (_aOn.contains(a.id)) {
        _aOn.remove(a.id);
        ctrl.pause();
      }
    }
  }

  void _autoScroll() {
    if (!_sc.hasClients) return;
    final x = _t * _pxMs;
    final off = _sc.offset;
    final vw = _sc.position.viewportDimension;
    if (x < off || x > off + vw - 24) {
      _sc.jumpTo(_c(x - 40, 0, _sc.position.maxScrollExtent));
    }
  }

  // ----- geri al / kaydet -----

  void _pushUndo() {
    _undo.add(jsonEncode(_p.toJson()));
    if (_undo.length > 30) _undo.removeAt(0);
  }

  void _undoLast() {
    if (_undo.isEmpty) return;
    _pause();
    final s = _undo.removeLast();
    setState(() {
      _p = Project.fromJson(Map<String, dynamic>.from(jsonDecode(s) as Map));
      _selKind = '';
      _selId = -1;
      _sub = '';
      _cropping = false;
      _t = math.min(_t, _p.totalMs);
    });
    for (final c in _p.clips) {
      _ctrl(c.path);
    }
    for (final a in _p.audios) {
      _ctrlA(a.path);
    }
    _seek(_t);
    saveProject(_p);
  }

  void _saveProject() {
    saveProject(_p);
  }

  void _select(String kind, int id) {
    setState(() {
      _selKind = kind;
      _selId = id;
      _sub = '';
      _cropping = false;
    });
  }

  void _setSub(String s) {
    setState(() => _sub = _sub == s ? '' : s);
  }

  VClip? get _selClip =>
      (_selKind == 'c' && _selId >= 0 && _selId < _p.clips.length)
          ? _p.clips[_selId]
          : null;
  TClip? get _selText => _selKind == 't'
      ? _p.texts.where((t) => t.id == _selId).firstOrNull
      : null;
  AClip? get _selAudio => _selKind == 'a'
      ? _p.audios.where((a) => a.id == _selId).firstOrNull
      : null;

  // ----- ekleme işlemleri -----

  Future<void> _addLayer() async {
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
              const Text('Katman Ekle',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: kRed, fontSize: 24)),
              const SizedBox(height: 14),
              PixelButton(
                label: 'Video',
                icon: Ico.video,
                onTap: () => Navigator.pop(ctx, 'v'),
              ),
              const SizedBox(height: 10),
              PixelButton(
                label: 'Yazı',
                icon: Ico.text,
                onTap: () => Navigator.pop(ctx, 't'),
              ),
              const SizedBox(height: 10),
              PixelButton(
                label: 'Ses',
                icon: VIco.music,
                onTap: () => Navigator.pop(ctx, 'a'),
              ),
            ],
          ),
        ),
      ),
    );
    if (choice == 'v') {
      await _addVideo();
    } else if (choice == 't') {
      await _addText();
    } else if (choice == 'a') {
      await _addAudio();
    }
  }

  Future<void> _addVideo() async {
    final x = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (x == null || !mounted) return;
    toast(context, 'Video ekleniyor...');
    final path = await importFile(x.path);
    final ctrl = await _ctrl(path);
    if (ctrl == null) {
      if (mounted) toast(context, 'Video açılamadı');
      return;
    }
    _pushUndo();
    final sz = ctrl.value.size;
    final dur = ctrl.value.duration.inMilliseconds;
    setState(() {
      _p.clips.add(VClip(
        path: path,
        srcMs: dur,
        vw: sz.width,
        vh: sz.height,
        startMs: 0,
        endMs: dur,
      ));
      _selKind = 'c';
      _selId = _p.clips.length - 1;
      _sub = '';
    });
    _saveProject();
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
    final tc = TClip(id: _p.nextId++, text: t.trim(), startMs: _t);
    setState(() {
      _p.texts.add(tc);
      _selKind = 't';
      _selId = tc.id;
      _sub = '';
    });
    _saveProject();
  }

  Future<void> _editText() async {
    final tc = _selText;
    if (tc == null) return;
    final t = await _askText(tc.text);
    if (t == null || t.trim().isEmpty || !mounted) return;
    _pushUndo();
    setState(() => tc.text = t.trim());
    _saveProject();
  }

  Future<void> _addAudio() async {
    final r = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (r == null || r.files.isEmpty || r.files.first.path == null) return;
    if (!mounted) return;
    toast(context, 'Ses ekleniyor...');
    final path = await importFile(r.files.first.path!);
    final ctrl = await _ctrlA(path);
    if (ctrl == null) {
      if (mounted) toast(context, 'Ses açılamadı');
      return;
    }
    _pushUndo();
    final ac = AClip(
      id: _p.nextId++,
      path: path,
      name: r.files.first.name,
      srcMs: ctrl.value.duration.inMilliseconds,
      startMs: _t,
    );
    setState(() {
      _p.audios.add(ac);
      _selKind = 'a';
      _selId = ac.id;
      _sub = '';
    });
    _saveProject();
  }

  // ----- klip işlemleri -----

  void _split() {
    if (_p.clips.isEmpty) return;
    final loc = _locate(_t);
    final idx = loc[0];
    final c = _p.clips[idx];
    final local = loc[1];
    if (local < 150 || c.durMs - local < 150) {
      toast(context, 'Oynatma çizgisini klibin ortasına getir');
      return;
    }
    _pause();
    _pushUndo();
    final cut = c.startMs + (local * c.speed).round();
    final b = VClip.fromJson(c.toJson());
    b.startMs = cut;
    b.inA = 0;
    c.endMs = cut;
    c.outA = 0;
    setState(() {
      _p.clips.insert(idx + 1, b);
      _selKind = 'c';
      _selId = idx;
    });
    _saveProject();
  }

  void _deleteSelected() {
    _pause();
    _pushUndo();
    setState(() {
      if (_selKind == 'c' && _selId >= 0 && _selId < _p.clips.length) {
        _p.clips.removeAt(_selId);
      } else if (_selKind == 't') {
        _p.texts.removeWhere((t) => t.id == _selId);
      } else if (_selKind == 'a') {
        final a = _selAudio;
        if (a != null) _ac[a.path]?.pause();
        _p.audios.removeWhere((x) => x.id == _selId);
      }
      _selKind = '';
      _selId = -1;
      _sub = '';
      _t = math.min(_t, _p.totalMs);
    });
    _seek(_t);
    _saveProject();
  }

  void _copyClip() {
    final c = _selClip;
    if (c == null) return;
    _pause();
    _pushUndo();
    final b = VClip.fromJson(c.toJson());
    setState(() {
      _p.clips.insert(_selId + 1, b);
      _selId = _selId + 1;
    });
    _saveProject();
  }

  void _rotateClip() {
    final c = _selClip;
    if (c == null) return;
    _pushUndo();
    setState(() {
      c.rot = (c.rot + 1) % 4;
      c.cl = 0;
      c.ct = 0;
      c.cr = 1;
      c.cb = 1;
    });
    _saveProject();
  }

  void _flipClip(bool h) {
    final c = _selClip;
    if (c == null) return;
    _pushUndo();
    setState(() {
      if (h) {
        c.flipH = !c.flipH;
      } else {
        c.flipV = !c.flipV;
      }
    });
    _saveProject();
  }

  bool _transOn(VClip c, int idx, int i) {
    return idx + 1 < _p.clips.length &&
        c.outA == kTransPairs[i][0] &&
        _p.clips[idx + 1].inA == kTransPairs[i][1];
  }

  void _setTransition(int i) {
    final idx = _selId;
    if (_selKind != 'c' || idx < 0 || idx + 1 >= _p.clips.length) {
      toast(context, 'Geçiş için bu kesitten sonra başka bir kesit olmalı');
      return;
    }
    final a = _p.clips[idx];
    final b = _p.clips[idx + 1];
    _pushUndo();
    setState(() {
      a.outA = kTransPairs[i][0];
      b.inA = kTransPairs[i][1];
      b.animMs = a.animMs;
    });
    _saveProject();
    _previewFrom(math.max(0, _clipStart(idx) + a.durMs - a.animMs - 400));
  }

  void _copyText() {
    final t = _selText;
    if (t == null) return;
    _pushUndo();
    final b = TClip.fromJson(t.toJson());
    b.id = _p.nextId++;
    b.x = _c(t.x + 0.05, 0, 1);
    b.y = _c(t.y + 0.08, 0, 1);
    setState(() {
      _p.texts.add(b);
      _selId = b.id;
    });
    _saveProject();
  }

  void _copyAudio() {
    final a = _selAudio;
    if (a == null) return;
    _pushUndo();
    final b = AClip.fromJson(a.toJson());
    b.id = _p.nextId++;
    b.startMs = a.startMs + a.srcMs;
    setState(() {
      _p.audios.add(b);
      _selId = b.id;
    });
    _saveProject();
  }

  void _previewFrom(int t) {
    _pause();
    _t = t;
    _play();
  }

  // ----- kırpma -----

  void _startCrop() {
    final c = _selClip;
    if (c == null) return;
    _pause();
    setState(() {
      _cropN = Rect.fromLTRB(c.cl, c.ct, c.cr, c.cb);
      _cropping = true;
    });
  }

  Rect _videoRect(VClip c) {
    final a = c.rw / c.rh;
    var w = _pw;
    var h = w / a;
    if (h > _ph) {
      h = _ph;
      w = h * a;
    }
    return Rect.fromLTWH((_pw - w) / 2, (_ph - h) / 2, w, h);
  }

  void _cropStart(Offset p, Rect vr) {
    final r = _cropN;
    final c = Rect.fromLTRB(
      vr.left + r.left * vr.width,
      vr.top + r.top * vr.height,
      vr.left + r.right * vr.width,
      vr.top + r.bottom * vr.height,
    );
    const th = 40.0;
    if ((p - c.topLeft).distance < th) {
      _cropMode = 1;
    } else if ((p - c.topRight).distance < th) {
      _cropMode = 2;
    } else if ((p - c.bottomLeft).distance < th) {
      _cropMode = 3;
    } else if ((p - c.bottomRight).distance < th) {
      _cropMode = 4;
    } else if (c.contains(p)) {
      _cropMode = 0;
    } else {
      _cropMode = -1;
    }
  }

  void _cropUpdate(Offset d, Rect vr) {
    final dx = d.dx / vr.width;
    final dy = d.dy / vr.height;
    final mw = 40 / vr.width;
    final mh = 40 / vr.height;
    var c = _cropN;
    switch (_cropMode) {
      case 0:
        {
          final w = c.width;
          final h = c.height;
          final l = _c(c.left + dx, 0, 1 - w);
          final t = _c(c.top + dy, 0, 1 - h);
          c = Rect.fromLTWH(l, t, w, h);
          break;
        }
      case 1:
        c = Rect.fromLTRB(_c(c.left + dx, 0, c.right - mw),
            _c(c.top + dy, 0, c.bottom - mh), c.right, c.bottom);
        break;
      case 2:
        c = Rect.fromLTRB(c.left, _c(c.top + dy, 0, c.bottom - mh),
            _c(c.right + dx, c.left + mw, 1), c.bottom);
        break;
      case 3:
        c = Rect.fromLTRB(_c(c.left + dx, 0, c.right - mw), c.top, c.right,
            _c(c.bottom + dy, c.top + mh, 1));
        break;
      case 4:
        c = Rect.fromLTRB(c.left, c.top, _c(c.right + dx, c.left + mw, 1),
            _c(c.bottom + dy, c.top + mh, 1));
        break;
      default:
        return;
    }
    setState(() => _cropN = c);
  }

  void _applyCrop() {
    final c = _selClip;
    if (c == null) return;
    _pushUndo();
    setState(() {
      c.cl = _cropN.left;
      c.ct = _cropN.top;
      c.cr = _cropN.right;
      c.cb = _cropN.bottom;
      _cropping = false;
    });
    _saveProject();
  }

  // ----- arka plan (yeşil ekran) -----

  Future<void> _pickBg() async {
    final c = _selClip;
    if (c == null) return;
    final x = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (x == null) return;
    final path = await importFile(x.path);
    _pushUndo();
    setState(() => c.bg = path);
    _saveProject();
  }

  // ----- dışa aktarma -----

  Future<String> _prepareFont(String dir) async {
    final f = File('$dir/Minecraft.ttf');
    if (!await f.exists()) {
      final data = await rootBundle.load('Minecraft.ttf');
      await f.writeAsBytes(data.buffer.asUint8List());
    }
    return f.path;
  }

  Future<void> _export() async {
    if (_p.clips.isEmpty) {
      toast(context, 'Önce bir video ekle');
      return;
    }
    _pause();
    final q = await showDialog<double>(
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
              const Text('Kaydet',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: kRed, fontSize: 24)),
              const SizedBox(height: 14),
              PixelButton(
                label: 'Normal (720p)',
                fontSize: 16,
                onTap: () => Navigator.pop(ctx, 1.0),
              ),
              const SizedBox(height: 10),
              PixelButton(
                label: 'Yüksek (1080p)',
                fontSize: 16,
                filled: false,
                onTap: () => Navigator.pop(ctx, 1.5),
              ),
            ],
          ),
        ),
      ),
    );
    if (q == null || !mounted) return;
    setState(() {
      _exporting = true;
      _cancelled = false;
      _expProgress = 0;
    });
    _log.clear();
    var ok = false;
    String? out;
    try {
      final tmp = await getTemporaryDirectory();
      out = '${tmp.path}/alpy_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final font = await _prepareFont(tmp.path);
      final cmd = await buildExportCommand(_p, q, out, font, tmp.path);
      final done = Completer<bool>();
      final total = math.max(1, _p.totalMs);
      await FFmpegKit.executeAsync(cmd, (session) async {
        final rc = await session.getReturnCode();
        if (!done.isCompleted) done.complete(ReturnCode.isSuccess(rc));
      }, (log) {
        _log.write(log.getMessage());
        _log.write('\n');
      }, (stats) {
        final ms = stats.getTime();
        if (mounted) {
          setState(() => _expProgress = _c(ms / total, 0, 1));
        }
      });
      ok = await done.future;
      if (ok) {
        await Gal.putVideo(out);
      }
    } catch (e) {
      _log.write('HATA: $e');
      ok = false;
    }
    if (!mounted) return;
    setState(() => _exporting = false);
    if (ok) {
      toast(context, 'Video galeriye kaydedildi!');
    } else if (!_cancelled) {
      _showError();
    }
  }

  void _showError() {
    var text = _log.toString();
    if (text.length > 1800) text = text.substring(text.length - 1800);
    showDialog<void>(
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
              const Text('Kaydedilemedi',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: kRed, fontSize: 22)),
              const SizedBox(height: 8),
              const Text('Bu yazının ekran görüntüsünü gönder:',
                  style: TextStyle(color: Colors.white, fontSize: 13)),
              const SizedBox(height: 8),
              Flexible(
                child: SingleChildScrollView(
                  child: SelectableText(
                    text,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 10, fontFamily: 'monospace'),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              PixelButton(
                label: 'Tamam',
                fontSize: 16,
                onTap: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----- önizleme -----

  Fx _clipFx(VClip c, int local) {
    final a = math.max(50, c.animMs).toDouble();
    final pin = c.inA == 0 ? 1.0 : _ease(_c(local / a, 0, 1));
    final pout = c.outA == 0 ? 1.0 : _ease(_c((c.durMs - local) / a, 0, 1));
    return _fxMerge(_fxOf(c.inA, pin), _fxOf(c.outA, pout));
  }

  Widget _videoLayer(double pw, double ph) {
    if (_p.clips.isEmpty) return const SizedBox.shrink();
    final loc = _locate(_t);
    final c = _p.clips[loc[0]];
    final ctrl = _vc[c.path];
    if (ctrl == null || !ctrl.value.isInitialized) {
      return const Center(child: CircularProgressIndicator(color: kRed));
    }
    final vw = ctrl.value.size.width;
    final vh = ctrl.value.size.height;
    final crop = _cropping && _selClip == c
        ? const Rect.fromLTRB(0, 0, 1, 1)
        : Rect.fromLTRB(c.cl, c.ct, c.cr, c.cb);
    final cw = crop.width;
    final ch = crop.height;
    final ax = cw >= 0.999 ? 0.0 : 2 * crop.left / (1 - cw) - 1;
    final ay = ch >= 0.999 ? 0.0 : 2 * crop.top / (1 - ch) - 1;
    final rw = c.rot.isOdd ? vh : vw;
    final rh = c.rot.isOdd ? vw : vh;
    Widget video = SizedBox(
      width: rw,
      height: rh,
      child: Transform.scale(
        scaleX: c.flipH ? -1.0 : 1.0,
        scaleY: c.flipV ? -1.0 : 1.0,
        child: RotatedBox(
          quarterTurns: c.rot % 4,
          child: SizedBox(width: vw, height: vh, child: VideoPlayer(ctrl)),
        ),
      ),
    );
    if (c.filter > 0 && c.filter < kVFilters.length) {
      video = ColorFiltered(
        colorFilter: ColorFilter.matrix(kVFilters[c.filter].matrix),
        child: video,
      );
    }
    Widget w = SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.contain,
        child: ClipRect(
          child: Align(
            alignment: Alignment(ax, ay),
            widthFactor: cw,
            heightFactor: ch,
            child: video,
          ),
        ),
      ),
    );
    if (_cropping && _selClip == c) return w;
    final fx = _clipFx(c, loc[1]);
    w = Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..translate(fx.dx * pw, fx.dy * ph)
        ..rotateZ(fx.rot)
        ..scale(c.sx * fx.sc, c.sy * fx.sc, 1.0),
      child: w,
    );
    return Opacity(opacity: _c(fx.op, 0, 1), child: w);
  }

  Widget _textWidget(TClip t, String s, double pw) {
    final fs = math.max(4.0, t.size * pw);
    final fill = Text(
      s,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'Minecraft',
        fontSize: fs,
        color: Color(t.color),
        shadows: t.shadow
            ? [Shadow(color: Colors.black, offset: Offset(fs * 0.07, fs * 0.07))]
            : null,
      ),
    );
    if (!t.outline) return fill;
    return Stack(
      children: [
        Text(
          s,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Minecraft',
            fontSize: fs,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = fs * 0.14
              ..strokeJoin = StrokeJoin.round
              ..color = Colors.black,
          ),
        ),
        fill,
      ],
    );
  }

  List<Widget> _textLayers(double pw, double ph) {
    final out = <Widget>[];
    for (final t in _p.texts) {
      if (_t < t.startMs || _t > t.startMs + t.durMs) continue;
      final local = _t - t.startMs;
      final a = math.max(50, t.animMs).toDouble();
      final pin = t.inA == 0 ? 1.0 : _ease(_c(local / a, 0, 1));
      final pout = t.outA == 0 ? 1.0 : _ease(_c((t.durMs - local) / a, 0, 1));
      final fx = _fxMerge(_fxOf(t.inA, pin), _fxOf(t.outA, pout));
      var s = t.text;
      if (t.inA == 9) {
        final n = (s.length * _c(local / a, 0, 1)).ceil();
        s = s.substring(0, math.min(s.length, math.max(1, n)));
      }
      Widget w = _textWidget(t, s, pw);
      if (_selKind == 't' && _selId == t.id) {
        w = Container(
          decoration: BoxDecoration(border: Border.all(color: kRed, width: 2)),
          child: w,
        );
      }
      final cx = t.x * pw;
      final cy = t.y * ph;
      out.add(Positioned(
        left: cx - 2000,
        top: cy - 2000,
        width: 4000,
        height: 4000,
        child: Center(
          child: Transform.translate(
            offset: Offset(fx.dx * pw, fx.dy * ph),
            child: Opacity(opacity: _c(fx.op, 0, 1), child: w),
          ),
        ),
      ));
    }
    return out;
  }

  void _onPreviewTap() {
    if (_cropping) return;
    if (_selKind == 'c') _startCrop();
  }

  Widget _preview() {
    final cs = canvasSize(_p.aspect, 1.0);
    return AspectRatio(
      aspectRatio: cs[0] / cs[1],
      child: LayoutBuilder(builder: (ctx, cons) {
        final pw = cons.maxWidth;
        final ph = cons.maxHeight;
        _pw = pw;
        _ph = ph;
        final sel = _selClip;
        Widget? bgImg;
        var chromaOn = false;
        if (_p.clips.isNotEmpty) {
          final cur = _p.clips[_locate(_t)[0]];
          chromaOn = cur.chroma;
          if (cur.chroma && cur.bg.isNotEmpty) {
            bgImg = Image.file(File(cur.bg), fit: BoxFit.cover);
          }
        }
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _onPreviewTap,
          onScaleStart: _cropping
              ? null
              : (d) {
                  final t = _selText;
                  if (t != null) {
                    _pushUndo();
                    _baseSize = t.size;
                  }
                },
          onScaleUpdate: _cropping
              ? null
              : (d) {
                  final t = _selText;
                  if (t == null) return;
                  setState(() {
                    t.x += d.focalPointDelta.dx / pw;
                    t.y += d.focalPointDelta.dy / ph;
                    if (d.pointerCount >= 2) {
                      t.size = _c(_baseSize * d.scale, 0.02, 0.4);
                    }
                  });
                },
          onScaleEnd: _cropping ? null : (d) => _saveProject(),
          child: ClipRect(
            child: Stack(
              children: [
                Positioned.fill(child: Container(color: Colors.black)),
                if (bgImg != null) Positioned.fill(child: bgImg),
                Positioned.fill(child: _videoLayer(pw, ph)),
                ..._textLayers(pw, ph),
                if (chromaOn)
                  Positioned(
                    left: 6,
                    top: 6,
                    child: Container(
                      color: Colors.black54,
                      padding: const EdgeInsets.all(4),
                      child: const Text('Yeşil ekran kaydedince uygulanır',
                          style: TextStyle(color: kRed, fontSize: 10)),
                    ),
                  ),
                if (_cropping && sel != null) _cropOverlay(sel, pw, ph),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _cropOverlay(VClip c, double pw, double ph) {
    final vr = _videoRect(c);
    final r = Rect.fromLTRB(
      vr.left + _cropN.left * vr.width,
      vr.top + _cropN.top * vr.height,
      vr.left + _cropN.right * vr.width,
      vr.top + _cropN.bottom * vr.height,
    );
    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (d) => _cropStart(d.localPosition, vr),
        onPanUpdate: (d) => _cropUpdate(d.delta, vr),
        child: CustomPaint(painter: _VCropPainter(r, vr)),
      ),
    );
  }

  // ----- zaman çizelgesi -----

  Widget _timeline() {
    final total = _p.totalMs;
    final screenW = MediaQuery.of(context).size.width;
    final w = math.max(screenW, total * _pxMs + 160.0);
    final blocks = <Widget>[];

    var acc = 0;
    for (var i = 0; i < _p.clips.length; i++) {
      final c = _p.clips[i];
      final idx = i;
      final sel = _selKind == 'c' && _selId == i;
      final bw = math.max(34.0, c.durMs * _pxMs - 2);
      blocks.add(Positioned(
        left: acc * _pxMs,
        top: 24,
        width: bw,
        height: 46,
        child: GestureDetector(
          onTap: () => _select('c', idx),
          child: Container(
            decoration: BoxDecoration(
              color: kDarkRed,
              border: Border.all(
                  color: sel ? Colors.white : kRed, width: sel ? 3 : 1),
            ),
            padding: const EdgeInsets.all(4),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Video ${i + 1}\n${(c.durMs / 1000).toStringAsFixed(1)}s',
                    maxLines: 2,
                    overflow: TextOverflow.clip,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
                if (sel)
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _deleteSelected,
                      child: Container(
                        color: kRed,
                        padding: const EdgeInsets.all(3),
                        child: const PixelIcon(Ico.trash,
                            size: 16, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ));
      acc += c.durMs;
    }

    for (final t in _p.texts) {
      final id = t.id;
      final sel = _selKind == 't' && _selId == id;
      blocks.add(Positioned(
        left: t.startMs * _pxMs,
        top: 76,
        width: math.max(34.0, t.durMs * _pxMs - 2),
        height: 34,
        child: GestureDetector(
          onTap: () => _select('t', id),
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF5A1010),
              border: Border.all(
                  color: sel ? Colors.white : kRed, width: sel ? 3 : 1),
            ),
            child: Text(
              t.text.replaceAll('\n', ' '),
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ),
        ),
      ));
    }

    for (final a in _p.audios) {
      final id = a.id;
      final sel = _selKind == 'a' && _selId == id;
      blocks.add(Positioned(
        left: a.startMs * _pxMs,
        top: 116,
        width: math.max(34.0, a.srcMs * _pxMs - 2),
        height: 34,
        child: GestureDetector(
          onTap: () => _select('a', id),
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF3A0A2A),
              border: Border.all(
                  color: sel ? Colors.white : kRed, width: sel ? 3 : 1),
            ),
            child: Text(
              a.name,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ),
        ),
      ));
    }

    return Container(
      height: 156,
      color: kBlack,
      child: SingleChildScrollView(
        controller: _sc,
        scrollDirection: Axis.horizontal,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (d) {
            _pause();
            final t = _c(d.localPosition.dx / _pxMs, 0, total.toDouble()).round();
            setState(() => _t = t);
            _seek(t);
          },
          child: SizedBox(
            width: w,
            height: 156,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  width: w,
                  height: 22,
                  child: CustomPaint(painter: _VRulerPainter(total, _pxMs)),
                ),
                ...blocks,
                Positioned(
                  left: _t * _pxMs - 1,
                  top: 0,
                  bottom: 0,
                  width: 2,
                  child: Container(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ----- paneller -----

  Widget _chip(String label, bool on, VoidCallback onTap, {List<String>? icon}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: on ? kRed : Colors.transparent,
          border: Border.all(color: kRed, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              PixelIcon(icon, size: 14, color: on ? Colors.white : kRed),
              const SizedBox(width: 5),
            ],
            Text(label,
                style: TextStyle(color: on ? Colors.white : kRed, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _chipRow(List<Widget> items) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        children: items,
      ),
    );
  }

  Widget _sl(String label, double value, double min, double max,
      void Function(double) apply,
      {String? txt}) {
    return Row(
      children: [
        SizedBox(
          width: 92,
          child: Text(label, style: const TextStyle(color: kRed, fontSize: 12)),
        ),
        Expanded(
          child: Slider(
            value: _c(value, min, max),
            min: min,
            max: max,
            onChangeStart: (_) => _pushUndo(),
            onChanged: (v) => setState(() => apply(v)),
            onChangeEnd: (_) => _saveProject(),
          ),
        ),
        SizedBox(
          width: 50,
          child: Text(
            txt ?? value.toStringAsFixed(2),
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _palette(int current, void Function(int) onPick) {
    return SizedBox(
      height: 38,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (final c in kPalette)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onPick(c.toARGB32()),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: c,
                  border: Border.all(
                    color: c.toARGB32() == current ? Colors.white : kDarkRed,
                    width: c.toARGB32() == current ? 3 : 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _animChips(int cur, List<int> allowed, void Function(int) onPick) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final a in allowed) _chip(kAnimNames[a], a == cur, () => onPick(a)),
        ],
      ),
    );
  }

  Widget _label(String s) => Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 2),
        child: Text(s, style: const TextStyle(color: Colors.white, fontSize: 12)),
      );

  Widget _panel() {
    Widget body = const SizedBox.shrink();
    if (_cropping) {
      body = _cropPanel();
    } else if (_selKind == 'c') {
      body = _clipPanel();
    } else if (_selKind == 't') {
      body = _textPanel();
    } else if (_selKind == 'a') {
      body = _audioPanel();
    } else {
      return const SizedBox.shrink();
    }
    return Container(
      color: kPanel,
      constraints: const BoxConstraints(maxHeight: 190),
      child: SingleChildScrollView(child: body),
    );
  }

  Widget _cropPanel() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: PixelButton(
              label: 'Vazgeç',
              filled: false,
              fontSize: 14,
              onTap: () => setState(() => _cropping = false),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: PixelButton(
              label: 'Sıfırla',
              filled: false,
              fontSize: 14,
              onTap: () =>
                  setState(() => _cropN = const Rect.fromLTRB(0, 0, 1, 1)),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: PixelButton(
              label: 'Kırp',
              fontSize: 14,
              onTap: _applyCrop,
            ),
          ),
        ],
      ),
    );
  }

  Widget _clipPanel() {
    final c = _selClip;
    if (c == null) return const SizedBox.shrink();
    final idx = _selId;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _chipRow([
          _chip('Böl', false, _split, icon: VIco.split),
          _chip('Sil', false, _deleteSelected, icon: Ico.trash),
          _chip('Kopyala', false, _copyClip),
          _chip('Hız', _sub == 'speed', () => _setSub('speed')),
          _chip('Ses', _sub == 'vol', () => _setSub('vol')),
          _chip('Döndür', false, _rotateClip, icon: Ico.rotate),
          _chip('Aynala', c.flipH, () => _flipClip(true)),
          _chip('Ters', c.flipV, () => _flipClip(false)),
          _chip('Basık', _sub == 'squash', () => _setSub('squash')),
          _chip('Kırp', false, _startCrop, icon: Ico.crop),
          _chip('Filtre', _sub == 'filter' || c.filter != 0, () => _setSub('filter')),
          _chip('Animasyon', _sub == 'anim', () => _setSub('anim')),
          _chip('Geçiş', _sub == 'trans', () => _setSub('trans')),
          _chip('Yeşil Ekran', c.chroma || _sub == 'chroma', () => _setSub('chroma')),
        ]),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_sub == 'speed')
                _sl('Hız', c.speed, 0.25, 4.0, (v) {
                  c.speed = double.parse(v.toStringAsFixed(2));
                  _t = math.min(_t, _p.totalMs);
                }, txt: '${c.speed.toStringAsFixed(2)}x'),
              if (_sub == 'vol') ...[
                _sl('Ses', c.volume, 0, 1, (v) {
                  c.volume = v;
                  _vc[c.path]?.setVolume(v);
                }, txt: '%${(c.volume * 100).round()}'),
                _sl('Yumuşat', c.fadeMs.toDouble(), 0, 3000,
                    (v) => c.fadeMs = v.round(),
                    txt: '${(c.fadeMs / 1000).toStringAsFixed(1)}s'),
              ],
              if (_sub == 'squash') ...[
                _sl('Genişlik', c.sx, 0.3, 2.0, (v) => c.sx = v,
                    txt: '${(c.sx * 100).round()}%'),
                _sl('Yükseklik', c.sy, 0.3, 2.0, (v) => c.sy = v,
                    txt: '${(c.sy * 100).round()}%'),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _chip('Sıfırla', false, () {
                    _pushUndo();
                    setState(() {
                      c.sx = 1;
                      c.sy = 1;
                    });
                    _saveProject();
                  }),
                ),
              ],
              if (_sub == 'filter')
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (var i = 0; i < kVFilters.length; i++)
                        _chip(kVFilters[i].name, c.filter == i, () {
                          _pushUndo();
                          setState(() => c.filter = i);
                          _saveProject();
                        }),
                    ],
                  ),
                ),
              if (_sub == 'anim') ...[
                _label('Giriş'),
                _animChips(c.inA, kClipAnims, (a) {
                  _pushUndo();
                  setState(() => c.inA = a);
                  _saveProject();
                  _previewFrom(_clipStart(idx));
                }),
                _label('Çıkış'),
                _animChips(c.outA, kClipAnims, (a) {
                  _pushUndo();
                  setState(() => c.outA = a);
                  _saveProject();
                  _previewFrom(math.max(0, _clipStart(idx) + c.durMs - c.animMs - 600));
                }),
                _sl('Süre', c.animMs.toDouble(), 100, 2000,
                    (v) => c.animMs = v.round(),
                    txt: '${(c.animMs / 1000).toStringAsFixed(1)}s'),
              ],
              if (_sub == 'trans') ...[
                _label('Bu kesitten sonraki kesite geçiş'),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (var i = 0; i < kTransNames.length; i++)
                        _chip(kTransNames[i], _transOn(c, idx, i),
                            () => _setTransition(i)),
                    ],
                  ),
                ),
                _sl('Süre', c.animMs.toDouble(), 100, 2000, (v) {
                  c.animMs = v.round();
                  if (idx + 1 < _p.clips.length) {
                    _p.clips[idx + 1].animMs = v.round();
                  }
                }, txt: '${(c.animMs / 1000).toStringAsFixed(1)}s'),
              ],
              if (_sub == 'chroma') ...[
                Row(
                  children: [
                    _chip(c.chroma ? 'Açık' : 'Kapalı', c.chroma, () {
                      _pushUndo();
                      setState(() => c.chroma = !c.chroma);
                      _saveProject();
                    }),
                    _chip('Arka Plan Seç', false, _pickBg, icon: Ico.photo),
                    if (c.bg.isNotEmpty)
                      _chip('Kaldır', false, () {
                        _pushUndo();
                        setState(() => c.bg = '');
                        _saveProject();
                      }),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 4, bottom: 6),
                  child: Text(
                    'Yeşil renk kaydedince silinir, yerine seçtiğin arka plan gelir.',
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _textPanel() {
    final t = _selText;
    if (t == null) return const SizedBox.shrink();
    final total = math.max(1000, _p.totalMs).toDouble();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _chipRow([
          _chip('Düzenle', false, _editText, icon: Ico.text),
          _chip('Kopyala', false, _copyText),
          _chip('Renk', _sub == 'color', () => _setSub('color')),
          _chip('Boyut', _sub == 'size', () => _setSub('size')),
          _chip('Zaman', _sub == 'time', () => _setSub('time')),
          _chip('Animasyon', _sub == 'anim', () => _setSub('anim')),
          _chip('Gölge', t.shadow, () {
            _pushUndo();
            setState(() => t.shadow = !t.shadow);
            _saveProject();
          }),
          _chip('Kenar', t.outline, () {
            _pushUndo();
            setState(() => t.outline = !t.outline);
            _saveProject();
          }),
          _chip('Sil', false, _deleteSelected, icon: Ico.trash),
        ]),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_sub == 'color')
                _palette(t.color, (c) {
                  _pushUndo();
                  setState(() => t.color = c);
                  _saveProject();
                }),
              if (_sub == 'size')
                _sl('Boyut', t.size, 0.02, 0.3, (v) => t.size = v,
                    txt: '${(t.size * 100).round()}%'),
              if (_sub == 'time') ...[
                _sl('Başlangıç', t.startMs.toDouble(), 0, total,
                    (v) => t.startMs = v.round(),
                    txt: '${(t.startMs / 1000).toStringAsFixed(1)}s'),
                _sl('Süre', t.durMs.toDouble(), 300, total + 5000,
                    (v) => t.durMs = v.round(),
                    txt: '${(t.durMs / 1000).toStringAsFixed(1)}s'),
              ],
              if (_sub == 'anim') ...[
                _label('Giriş'),
                _animChips(t.inA, kTextAnims, (a) {
                  _pushUndo();
                  setState(() => t.inA = a);
                  _saveProject();
                  _previewFrom(t.startMs);
                }),
                _label('Çıkış'),
                _animChips(t.outA, kTextAnims.where((e) => e != 9).toList(), (a) {
                  _pushUndo();
                  setState(() => t.outA = a);
                  _saveProject();
                  _previewFrom(math.max(0, t.startMs + t.durMs - t.animMs - 600));
                }),
                _sl('Süre', t.animMs.toDouble(), 100, 2000,
                    (v) => t.animMs = v.round(),
                    txt: '${(t.animMs / 1000).toStringAsFixed(1)}s'),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _audioPanel() {
    final a = _selAudio;
    if (a == null) return const SizedBox.shrink();
    final total = math.max(1000, _p.totalMs).toDouble();
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _sl('Ses', a.volume, 0, 1, (v) {
            a.volume = v;
            _ac[a.path]?.setVolume(v);
          }, txt: '%${(a.volume * 100).round()}'),
          _sl('Başlangıç', a.startMs.toDouble(), 0, total,
              (v) => a.startMs = v.round(),
              txt: '${(a.startMs / 1000).toStringAsFixed(1)}s'),
          _sl('Açılış', a.fadeInMs.toDouble(), 0, 5000,
              (v) => a.fadeInMs = v.round(),
              txt: '${(a.fadeInMs / 1000).toStringAsFixed(1)}s'),
          _sl('Kapanış', a.fadeOutMs.toDouble(), 0, 5000,
              (v) => a.fadeOutMs = v.round(),
              txt: '${(a.fadeOutMs / 1000).toStringAsFixed(1)}s'),
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _chip('Kopyala', false, _copyAudio),
                _chip('Sil', false, _deleteSelected, icon: Ico.trash),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ----- üst / alt çubuklar -----

  Widget _topBar() {
    return Row(
      children: [
        IconTap(
          icon: Ico.back,
          onTap: () {
            _pause();
            saveProject(_p);
            Navigator.pop(context);
          },
        ),
        Expanded(
          child: Center(
            child: Text(_p.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: kRed, fontSize: 16)),
          ),
        ),
        IconTap(icon: Ico.undo, onTap: _undo.isEmpty ? null : _undoLast),
        IconTap(icon: VIco.export, onTap: _export),
      ],
    );
  }

  Widget _controls() {
    final total = math.max(1, _p.totalMs);
    return Container(
      color: kPanel,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          IconTap(
            icon: _playing ? VIco.pause : VIco.play,
            onTap: _togglePlay,
            size: 24,
          ),
          Expanded(
            child: Slider(
              value: _c(_t.toDouble(), 0, total.toDouble()),
              min: 0,
              max: total.toDouble(),
              onChangeStart: (_) {
                if (_playing) _pause();
              },
              onChanged: (v) {
                setState(() => _t = v.round());
                _seek(_t);
              },
            ),
          ),
          Text('${_fmt(_t)}/${_fmt(_p.totalMs)}',
              style: const TextStyle(color: Colors.white, fontSize: 11)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              _pushUndo();
              setState(() => _p.aspect = (_p.aspect + 1) % 3);
              _saveProject();
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: kRed, width: 2),
              ),
              child: Text(['9:16', '16:9', '1:1'][_p.aspect],
                  style: const TextStyle(color: kRed, fontSize: 12)),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _pxMs = _c(_pxMs / 1.5, 0.02, 0.4)),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Text('-', style: TextStyle(color: kRed, fontSize: 22)),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _pxMs = _c(_pxMs * 1.5, 0.02, 0.4)),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Text('+', style: TextStyle(color: kRed, fontSize: 22)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _exportOverlay() {
    return Positioned.fill(
      child: Container(
        color: const Color(0xEE000000),
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Video hazırlanıyor...',
                textAlign: TextAlign.center,
                style: TextStyle(color: kRed, fontSize: 24)),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: _expProgress,
              minHeight: 14,
              color: kRed,
              backgroundColor: kDarkRed,
            ),
            const SizedBox(height: 10),
            Text('%${(_expProgress * 100).round()}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 20)),
            const SizedBox(height: 24),
            PixelButton(
              label: 'İptal',
              filled: false,
              fontSize: 16,
              onTap: () {
                _cancelled = true;
                FFmpegKit.cancel();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _topBar(),
                Expanded(child: Center(child: _preview())),
                _controls(),
                _timeline(),
                _panel(),
                Container(
                  color: kPanel,
                  padding: const EdgeInsets.all(8),
                  child: PixelButton(
                    label: 'Katman Ekle',
                    icon: Ico.plus,
                    fontSize: 16,
                    onTap: _addLayer,
                  ),
                ),
              ],
            ),
            if (_exporting) _exportOverlay(),
          ],
        ),
      ),
    );
  }
}
