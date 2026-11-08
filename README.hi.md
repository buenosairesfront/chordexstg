[English](README.md) · [Español](README.es.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [日本語](README.ja.md) · [中文](README.zh.md) · **हिन्दी**

# ChordexSTG

[monome norns](https://monome.org/docs/norns/) के लिए एक ऑर्केस्ट्रा स्ट्रिंग सेक्शन: एक बटन चार नोट का कॉर्ड (साथ में बेस) बजाता है, जिसे वायलिन, वियोला, चेलो, डबल बेस या पूरा ऑर्केस्ट्रा गज़ (bow) से बजाता है।

![ChordexSTG](docs/sheet.png)

**स्क्रीन ही वाद्य है।** बीच में चारों तार सामने से दिखते हैं, फ़िंगरबोर्ड से ब्रिज तक, और किनारों पर f-आकार के छेद। कॉर्ड का हर नोट अपने तार पर उसी तरह कंपन करता है जैसे गज़ से बजाया गया असली तार (हेल्महोल्ट्ज़ गति: एक कोना जो उँगली और ब्रिज के बीच दौड़ता है)। उँगली दिखाती है कि नोट कहाँ दबाया गया है और वाइब्रेटो के साथ झूलती है। गज़ तारों को पार करता है: उसकी ऊँचाई ध्वनि का रंग है (ऊपर sul tasto, नीचे sul ponticello) और उसकी गति डायनेमिक्स। स्पिकाटो में वह उछलता है, ट्रेमोलो में काँपता है और पिज़िकाटो में ऊपर उठ जाता है। रोज़िन की धूल गज़ का दबाव दिखाती है; ऊपर उठती चिंगारियाँ "आकाश" (shimmer) दिखाती हैं।

- बाएँ: 12 नोट के चक्र पर कॉर्ड, आर्टिक्यूलेशन का एनवेलप और 9 फ़ेडर
- दाएँ: ऑसिलोस्कोप, बॉडी रेज़ोनेंस वक्र के साथ हार्मोनिक्स, आर्पेजियो पैटर्न; ऊपर सेक्शन, आर्टिक्यूलेशन और होल्ड
- नीचे बाएँ: डायनेमिक्स का क्रेसेंडो चिह्न (<)

## विशेषताएँ

- **5 सेक्शन**, हर एक अपने रजिस्टर और अपनी बॉडी के साथ: VIOLIN (एक ऑक्टेव ऊपर), VIOLA, CELLO (एक ऑक्टेव नीचे), CONTRABAJO (डबल बेस, दो ऑक्टेव नीचे) और **TUTTI**, जो कॉर्ड को पूरे ऑर्केस्ट्रा में मंच की बैठक के अनुसार बाँटता है
- **4 आर्टिक्यूलेशन**: लेगाटो, स्पिकाटो, पिज़िकाटो, ट्रेमोलो — कॉर्ड और आर्पेजियो दोनों के लिए
- **12 कॉर्ड**: maj, min, dim, aug, 7, maj7, min7, m7b5, sus2, sus4, 5, add9
- **आर्पेजिएटर**: up, down, up-down, up x2, down x2, random और *arpa* (हार्प); गेट अधिकतम पर असली लेगाटो, गज़ एक नोट से दूसरे पर फिसलता है
- **कॉर्ड मोड** चालू/बंद (बंद = एक नोट) और **होल्ड**
- आर्पेजियो की गति आने वाली MIDI क्लॉक का पालन करती है
- सभी सेटिंग्स अपने आप सेव होती हैं

<!-- u-ma:family -->
## Chordex परिवार

कंट्रोल वही, इंजन अलग। बाकी भी आज़माएँ:

| | |
|---|---|
| <a href="https://github.com/buenosairesfront/chordex80/blob/main/README.hi.md"><img src="https://raw.githubusercontent.com/buenosairesfront/chordex80/main/docs/1_d50.png" width="200" alt="Chordex 80"></a> | **[Chordex 80](https://github.com/buenosairesfront/chordex80/blob/main/README.hi.md)**<br>outrun सूर्यास्त वाला 80 के दशक का पॉलीसिंथ<br>`;install https://github.com/buenosairesfront/chordex80` |
| <a href="https://github.com/buenosairesfront/chordexfm/blob/main/README.hi.md"><img src="https://raw.githubusercontent.com/buenosairesfront/chordexfm/main/docs/3_metal.png" width="200" alt="Chordex FM"></a> | **[Chordex FM](https://github.com/buenosairesfront/chordexfm/blob/main/README.hi.md)**<br>4-ऑपरेटर FM, फूल के रूप में<br>`;install https://github.com/buenosairesfront/chordexfm` |
| <a href="https://github.com/buenosairesfront/chordexwt/blob/main/README.hi.md"><img src="https://raw.githubusercontent.com/buenosairesfront/chordexwt/main/docs/2_vocal.png" width="200" alt="Chordex WT"></a> | **[Chordex WT](https://github.com/buenosairesfront/chordexwt/blob/main/README.hi.md)**<br>वेवटेबल: 8 वेव वाले 8 बैंक, 3D टेबल के रूप में<br>`;install https://github.com/buenosairesfront/chordexwt` |
| <a href="https://github.com/buenosairesfront/chordexchip/blob/main/README.hi.md"><img src="https://raw.githubusercontent.com/buenosairesfront/chordexchip/main/docs/1_nes.png" width="200" alt="Chordex CHIP"></a> | **[Chordex CHIP](https://github.com/buenosairesfront/chordexchip/blob/main/README.hi.md)**<br>चिपट्यून: 8 कंसोल चिप × 8 प्रीसेट, ट्रैकर के रूप में<br>`;install https://github.com/buenosairesfront/chordexchip` |
| <a href="https://github.com/buenosairesfront/chordexabnt/blob/main/README.hi.md"><img src="https://raw.githubusercontent.com/buenosairesfront/chordexabnt/main/docs/1_warm_pad.png" width="200" alt="Chordex ABNT"></a> | **[Chordex ABNT](https://github.com/buenosairesfront/chordexabnt/blob/main/README.hi.md)**<br>पैड, एंबिएंट, लीड और टेक्सचर: 4 परिवार × 8 प्रीसेट, आर्पेजिएटर की जगह मूवमेंट<br>`;install https://github.com/buenosairesfront/chordexabnt` |

**U-MA से और:** सभी वाद्य और टूल एक जगह → [U-MA शोकेस](https://github.com/buenosairesfront/U-ma/blob/main/README.hi.md)
<!-- /u-ma:family -->

## ज़रूरतें

- norns (shield, standard या fates)
- MIDI कीबोर्ड या कंट्रोलर

## इंस्टॉल

maiden में:

```
;install https://github.com/buenosairesfront/chordexstg
```

फिर नया इंजन `ChordexSTG` कंपाइल होने के लिए **norns को रीस्टार्ट करें** (SYSTEM > RESTART), और SELECT से **chordexstg** लोड करें।

## कंट्रोल

| कंट्रोल | काम |
|---|---|
| E1 | डायनेमिक्स (pp … ff) |
| E2 | फ़ेडर चुनें |
| E3 | फ़ेडर समायोजित करें |
| K3 + E1 | सेक्शन |
| K3 + E2 | आर्टिक्यूलेशन |
| K3 + E3 | कॉर्ड का प्रकार |
| K2 (टैप) | आर्पेजिएटर चालू/बंद |
| K2 + E1 | आर्पेजियो गेट (अधिकतम = लेगाटो) |
| K2 + E2 | आर्पेजियो पैटर्न |
| K2 + E3 | आर्पेजियो गति |
| K3 दबाए रखें (बिना घुमाए) | कॉर्ड मोड चालू/बंद |
| K1 दबाए रखें | होल्ड चालू/बंद (ऊपर दाएँ छोटा हीरा) |

**फ़ेडर:** अटैक, रिलीज़, रंग, गज़ का दबाव, वाइब्रेटो, वाइब्रेटो की गति, एन्सेम्बल, स्वेल (क्रेसेंडो), आकाश।

**PARAMETERS मेनू:** MIDI चैनल (0 = सभी, डिफ़ॉल्ट), MIDI क्लॉक डिवाइडर, ऑक्टेव, बेस स्तर, कमरा (room), वॉल्यूम, और ऊपर का सब कुछ।

## गैलरी

| | |
|---|---|
| ![वायलिन, लेगाटो](docs/1_violin.png) वायलिन · लेगाटो | ![टुट्टी](docs/2_tutti.png) टुट्टी |
| ![चेलो, ट्रेमोलो](docs/3_cello_tremolo.png) चेलो · ट्रेमोलो | ![वियोला, पिज़िकाटो, आर्पेजियो](docs/4_viola_pizz_arp.png) वियोला · पिज़िकाटो · आर्पेजियो |
| ![डबल बेस](docs/5_contrabajo.png) डबल बेस | |

## श्रेय

[Buenos Aires Front](https://github.com/buenosairesfront) / U-MA द्वारा बनाया गया, U-MA / Chordex परिवार का हिस्सा।
MIT लाइसेंस।
