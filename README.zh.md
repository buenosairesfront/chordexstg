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
- 琶音速度跟随外部 MIDI 时钟
- 所有设置自动保存

<!-- u-ma:family -->
## Chordex 系列

操作相同，引擎不同。也来试试其他几款：

| | |
|---|---|
| <a href="https://github.com/buenosairesfront/chordex80/blob/main/README.zh.md"><img src="https://raw.githubusercontent.com/buenosairesfront/chordex80/main/docs/1_d50.png" width="200" alt="Chordex 80"></a> | **[Chordex 80](https://github.com/buenosairesfront/chordex80/blob/main/README.zh.md)**<br>80 年代复音合成器，配 outrun 日落画面<br>`;install https://github.com/buenosairesfront/chordex80` |
| <a href="https://github.com/buenosairesfront/chordexfm/blob/main/README.zh.md"><img src="https://raw.githubusercontent.com/buenosairesfront/chordexfm/main/docs/3_metal.png" width="200" alt="Chordex FM"></a> | **[Chordex FM](https://github.com/buenosairesfront/chordexfm/blob/main/README.zh.md)**<br>4 算子 FM，画成一朵花<br>`;install https://github.com/buenosairesfront/chordexfm` |
| <a href="https://github.com/buenosairesfront/chordexwt/blob/main/README.zh.md"><img src="https://raw.githubusercontent.com/buenosairesfront/chordexwt/main/docs/2_vocal.png" width="200" alt="Chordex WT"></a> | **[Chordex WT](https://github.com/buenosairesfront/chordexwt/blob/main/README.zh.md)**<br>波表：8 个库、每库 8 个波形，画成 3D 波表<br>`;install https://github.com/buenosairesfront/chordexwt` |
| <a href="https://github.com/buenosairesfront/chordexchip/blob/main/README.zh.md"><img src="https://raw.githubusercontent.com/buenosairesfront/chordexchip/main/docs/1_nes.png" width="200" alt="Chordex CHIP"></a> | **[Chordex CHIP](https://github.com/buenosairesfront/chordexchip/blob/main/README.zh.md)**<br>芯片音乐：8 种游戏机芯片 × 8 个预设，画成 tracker<br>`;install https://github.com/buenosairesfront/chordexchip` |
| <a href="https://github.com/buenosairesfront/chordexabnt/blob/main/README.zh.md"><img src="https://raw.githubusercontent.com/buenosairesfront/chordexabnt/main/docs/1_warm_pad.png" width="200" alt="Chordex ABNT"></a> | **[Chordex ABNT](https://github.com/buenosairesfront/chordexabnt/blob/main/README.zh.md)**<br>铺底、氛围、主奏和纹理：4 个系列 × 8 个预设，用“运动”取代琶音器<br>`;install https://github.com/buenosairesfront/chordexabnt` |

**更多 U-MA 作品：** 所有乐器和工具汇集一处 → [U-MA 作品集](https://github.com/buenosairesfront/U-ma/blob/main/README.zh.md)
<!-- /u-ma:family -->

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

**PARAMETERS 菜单：** MIDI 通道（默认 1；0 = 全部）、MIDI 时钟分频、八度、低音音量、房间、音量，以及以上所有参数。

## arc 和 crow

两者都是可选的：不连接 arc 或 crow 时一切照旧。

**arc**（4 个圆环，显示为旋钮）：1 力度 · 2 音色 · 3 琶音速度 · 4 房间

**crow**：IN1 = 音高（V/oct，0 V = C4），IN2 = 门（触发与释放） · OUT1 = 和弦根音（V/oct） · OUT2 = 包络（0–8 V，跟随声音的起音和释放） · OUT3 = 与速度同步的 LFO（1 小节） · OUT4 = 每个和弦或琶音步进一个脉冲。可在 PARAMETERS > ARC / CROW 中关闭。

**速度：** 首次启动时内部速度为 50 BPM。只要有 MIDI 时钟输入（任意 MIDI 端口），就以它为准。

## 图库

| | |
|---|---|
| ![小提琴，连奏](docs/1_violin.png) 小提琴 · 连奏 | ![全奏](docs/2_tutti.png) 全奏 |
| ![大提琴，震音](docs/3_cello_tremolo.png) 大提琴 · 震音 | ![中提琴，拨弦，琶音](docs/4_viola_pizz_arp.png) 中提琴 · 拨弦 · 琶音 |
| ![低音提琴](docs/5_contrabajo.png) 低音提琴 | |

## 致谢

由 [Buenos Aires Front](https://github.com/buenosairesfront) / U-MA 制作，属于 U-MA / Chordex 系列。
MIT 许可证。
