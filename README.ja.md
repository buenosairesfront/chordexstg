[English](README.md) · [Español](README.es.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · **日本語** · [中文](README.zh.md) · [हिन्दी](README.hi.md)

# ChordexSTG

[monome norns](https://monome.org/docs/norns/) 用のオーケストラ弦楽セクション。
1 つのキーで 4 音のコード（＋ベース）を、ヴァイオリン、ヴィオラ、チェロ、コントラバス、またはオーケストラ全体が弓で奏でます。

![ChordexSTG](docs/sheet.png)

**画面そのものが楽器です。** 中央には 4 本の弦が正面から、指板から駒まで描かれ、両脇に f 字孔があります。コードの各音は自分の弦の上で、弓で擦った弦の実際の動き（ヘルムホルツ運動：指と駒のあいだを角が往復する）で振動します。指は音を押さえている位置を示し、ビブラートに合わせて揺れます。弓は弦を横切り、その高さが音色（上 = スル・タスト、下 = スル・ポンティチェロ）、速さが強弱を表します。スピッカートでは跳ね、トレモロでは震え、ピッツィカートでは弓が離れます。松脂の粉は弓圧を、立ち上る火花は「空（シマー）」を表します。

- 左：12 音の輪の上のコード、アーティキュレーションのエンベロープ、9 本のフェーダー
- 右：オシロスコープ、胴の共鳴カーブを重ねた倍音、アルペジオのパターン。上部にセクション、アーティキュレーション、ホールド
- 左下：強弱のヘアピン（<）

## 機能

- **5 つのセクション**。それぞれ固有の音域と胴を持つ：VIOLIN（1 オクターブ上）、VIOLA、CELLO（1 オクターブ下）、CONTRABAJO（コントラバス、2 オクターブ下）、そしてステージ上の配置どおりにオーケストラ全体へコードを振り分ける **TUTTI**
- **4 つのアーティキュレーション**：レガート、スピッカート、ピッツィカート、トレモロ（コードにもアルペジオにも有効）
- **12 種類のコード**：maj, min, dim, aug, 7, maj7, min7, m7b5, sus2, sus4, 5, add9
- **アルペジエーター**：up, down, up-down, up x2, down x2, random, *arpa*（ハープ）。ゲート最大で本物のレガート（弓が音から音へ滑る）
- **コードモード** オン/オフ（オフ = 単音）と**ホールド**
- アルペジオのテンポは受信した MIDI クロックに追従
- すべての設定は自動保存

<!-- u-ma:family -->
## Chordex ファミリー

操作は同じ、エンジンは別。ほかの楽器もどうぞ：

| | |
|---|---|
| <a href="https://github.com/buenosairesfront/chordex80/blob/main/README.ja.md"><img src="https://raw.githubusercontent.com/buenosairesfront/chordex80/main/docs/1_d50.png" width="200" alt="Chordex 80"></a> | **[Chordex 80](https://github.com/buenosairesfront/chordex80/blob/main/README.ja.md)**<br>アウトランの夕焼けを描く 80 年代ポリシンセ<br>`;install https://github.com/buenosairesfront/chordex80` |
| <a href="https://github.com/buenosairesfront/chordexfm/blob/main/README.ja.md"><img src="https://raw.githubusercontent.com/buenosairesfront/chordexfm/main/docs/3_metal.png" width="200" alt="Chordex FM"></a> | **[Chordex FM](https://github.com/buenosairesfront/chordexfm/blob/main/README.ja.md)**<br>花として描かれる 4 オペレーター FM<br>`;install https://github.com/buenosairesfront/chordexfm` |
| <a href="https://github.com/buenosairesfront/chordexwt/blob/main/README.ja.md"><img src="https://raw.githubusercontent.com/buenosairesfront/chordexwt/main/docs/2_vocal.png" width="200" alt="Chordex WT"></a> | **[Chordex WT](https://github.com/buenosairesfront/chordexwt/blob/main/README.ja.md)**<br>8 波形 × 8 バンクのウェーブテーブル。3D テーブルとして描画<br>`;install https://github.com/buenosairesfront/chordexwt` |
| <a href="https://github.com/buenosairesfront/chordexchip/blob/main/README.ja.md"><img src="https://raw.githubusercontent.com/buenosairesfront/chordexchip/main/docs/1_nes.png" width="200" alt="Chordex CHIP"></a> | **[Chordex CHIP](https://github.com/buenosairesfront/chordexchip/blob/main/README.ja.md)**<br>チップチューン：ゲーム機チップ 8 種 × 8 プリセット、トラッカーとして描画<br>`;install https://github.com/buenosairesfront/chordexchip` |

**U-MA のほかの作品：** すべての楽器とツールをひとつに → [U-MA ショーケース](https://github.com/buenosairesfront/U-ma/blob/main/README.ja.md)
<!-- /u-ma:family -->

## 必要なもの

- norns（shield、標準モデル、fates）
- MIDI キーボードまたはコントローラー

## インストール

maiden から：

```
;install https://github.com/buenosairesfront/chordexstg
```

その後、新しいエンジン `ChordexSTG` をコンパイルするために **norns を再起動**（SYSTEM > RESTART）し、SELECT から **chordexstg** を読み込みます。

## 操作

| 操作 | 機能 |
|---|---|
| E1 | 強弱（pp … ff） |
| E2 | フェーダー選択 |
| E3 | フェーダー調整 |
| K3 + E1 | セクション |
| K3 + E2 | アーティキュレーション |
| K3 + E3 | コードの種類 |
| K2（タップ） | アルペジエーター オン/オフ |
| K2 + E1 | アルペジオのゲート（最大 = レガート） |
| K2 + E2 | アルペジオのパターン |
| K2 + E3 | アルペジオの速度 |
| K3 長押し（回さずに） | コードモード オン/オフ |
| K1 長押し | ホールド オン/オフ（右上の小さなひし形） |

**フェーダー：** アタック、リリース、音色、弓圧、ビブラート、ビブラートの速さ、アンサンブル、スウェル（クレッシェンド）、空。

**PARAMETERS メニュー：** MIDI チャンネル（0 = 全チャンネル、初期値）、MIDI クロック分周、オクターブ、ベース音量、ルーム、音量、および上記すべて。

## ギャラリー

| | |
|---|---|
| ![ヴァイオリン、レガート](docs/1_violin.png) ヴァイオリン · レガート | ![トゥッティ](docs/2_tutti.png) トゥッティ |
| ![チェロ、トレモロ](docs/3_cello_tremolo.png) チェロ · トレモロ | ![ヴィオラ、ピッツィカート、アルペジオ](docs/4_viola_pizz_arp.png) ヴィオラ · ピッツィカート · アルペジオ |
| ![コントラバス](docs/5_contrabajo.png) コントラバス | |

## クレジット

制作：[Buenos Aires Front](https://github.com/buenosairesfront) / U-MA（U-MA / Chordex ファミリー）。
MIT ライセンス。
