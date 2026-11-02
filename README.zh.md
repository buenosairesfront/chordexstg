[English](README.md) · [Español](README.es.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [日本語](README.ja.md) · **中文** · [हिन्दी](README.hi.md)

# ChordexSTG

为 [monome norns](https://monome.org/docs/norns/) 设计的管弦乐弦乐组：按一个键，就会由小提琴、中提琴、大提琴、低音提琴或整个乐团用弓拉奏出一个四音和弦（外加低音）。

![ChordexSTG](docs/sheet.png)

**屏幕就是乐器。** 中央是从正面看到的四根弦，从指板一直到琴码，两侧是 f 孔。和弦中的每个音都在自己的弦上，以真实拉弦的运动方式振动（亥姆霍兹运动：一个折角在手指和琴码之间来回奔跑）。手指标出按弦的位置，并随揉弦摆动。琴弓横跨琴弦：它的高度代表音色（上 = 指板上方奏法 sul tasto，下 = 近琴码奏法 sul ponticello），速度代表力度。顿弓时弹跳，震音时颤动，拨弦时抬起。松香粉末表示弓压，向上飘的火花表示「天空」shimmer 效果。

- 左侧：12 音轮上的和弦、奏法包络和 9 个推子
- 右侧：示波器、叠加琴身共鸣曲线的泛音、琶音型；上方显示声部、奏法和保持
- 左下：力度渐强记号（<）

## 功能

- **5 个声部**，各有自己的音域和琴身：VIOLIN（高八度）、VIOLA、CELLO（低八度）、CONTRABAJO（低音提琴，低两个八度），以及按舞台座位把和弦分配给整个乐团的 **TUTTI**
- **4 种奏法**：连奏、顿弓、拨弦、震音——和弦与琶音均适用
- **12 种和弦**：maj, min, dim, aug, 7, maj7, min7, m7b5, sus2, sus4, 5, add9
- **琶音器**：up, down, up-down, up x2, down x2, random 和 *arpa*（竖琴）；门限调到最大即为真正的连奏，琴弓在音与音之间滑动
- **和弦模式** 开/关（关 = 单音）以及**保持**
- 同时按住两个以上的键时，会出现老唱片的噼啪声
- 琶音速度跟随外部 MIDI 时钟
- 所有设置自动保存

## 需求

- norns（shield、标准版或 fates）
- MIDI 键盘或控制器

## 安装

在 maiden 中输入：

```
;install https://github.com/buenosairesfront/chordexstg
```

然后**重启 norns**（SYSTEM > RESTART）以编译新引擎 `ChordexSTG`，再从 SELECT 加载 **chordexstg**。

## 操作

| 操作 | 功能 |
|---|---|
| E1 | 力度（pp … ff） |
| E2 | 选择推子 |
| E3 | 调节推子 |
| K3 + E1 | 声部 |
| K3 + E2 | 奏法 |
| K3 + E3 | 和弦类型 |
| K2（轻按） | 琶音器 开/关 |
| K2 + E1 | 琶音门限（最大 = 连奏） |
| K2 + E2 | 琶音型 |
| K2 + E3 | 琶音速度 |
| 按住 K3（不转动旋钮） | 和弦模式 开/关 |
| 按住 K1 | 保持 开/关（右上角的小菱形） |

**推子：** 起音、释音、音色、弓压、揉弦、揉弦速度、合奏感、渐强（swell）、天空。

**PARAMETERS 菜单：** MIDI 通道（0 = 全部，默认）、MIDI 时钟分频、八度、低音音量、房间、音量，以及以上所有参数。

## 图库

| | |
|---|---|
| ![小提琴，连奏](docs/1_violin.png) 小提琴 · 连奏 | ![全奏](docs/2_tutti.png) 全奏 |
| ![大提琴，震音](docs/3_cello_tremolo.png) 大提琴 · 震音 | ![中提琴，拨弦，琶音](docs/4_viola_pizz_arp.png) 中提琴 · 拨弦 · 琶音 |
| ![低音提琴](docs/5_contrabajo.png) 低音提琴 | |

## 致谢

由 [Buenos Aires Front](https://github.com/buenosairesfront) / U-MA 制作，属于 U-MA / Chordex 系列。
MIT 许可证。
