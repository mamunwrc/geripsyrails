## NEXT

##[201903.0.1](https://github.com/jonuts/GeriPsy/compare/201903.0...201903.0.1)
* HOTFIX
  - only use password auth when talking to HP sftp server

## [201903.0](https://github.com/jonuts/GeriPsy/compare/201901.1...201903.0)
* [Group Therapy Modifier](https://github.com/jonuts/GeriPsy/pull/127)
* [Referring DR](https://github.com/jonuts/GeriPsy/pull/126)
  - Send HP a referring DR in testing note claims

## [201901.1](https://github.com/jonuts/GeriPsy/compare/201901.0...201901.1)
* [Jan 2019 Medicare Changes](https://github.com/jonuts/GeriPsy/pull/125)

## [201901.0](https://github.com/jonuts/GeriPsy/compare/201804.0...201901.0)
* [Testing Note](https://github.com/jonuts/GeriPsy/pull/121)
  - New note template for psych testing evaluations
* [New Medicare](https://github.com/jonuts/GeriPsy/pull/123)
  - Adds new medicare option for facilities
* [TP Fix](https://github.com/jonuts/GeriPsy/pull/122)
  - Ensure at least one option in Goals section filled in

## [201804.0](https://github.com/jonuts/GeriPsy/compare/201803.1...201804.0)
* HOTFIX
  - 59 modifier should be on both 9084x and 9083x

## [201803.1](https://github.com/jonuts/GeriPsy/compare/201803.0...201803.1)
* [Primary Provider Requirement](https://github.com/jonuts/GeriPsy/pull/120)
  - Dont require Primary for patient without any providers
* [Fallback Primary Provider](https://github.com/jonuts/GeriPsy/pull/119)
  - setting new primary if current provider was primary and removed from
    patient

## [201803.0](https://github.com/jonuts/GeriPsy/compare/201802.0.2...201803.0)
* [Facility POS](https://github.com/jonuts/GeriPsy/pull/118)
  - Allows billing with HP to use facility POS code 31 or 32

## [201802.0.2](https://github.com/jonuts/GeriPsy/compare/201802.0.1...201802.0.2)
* HOTFIX
  - add freetext field to TP discharge reasons
  - actually display discharge reasons on printouts/exports

## [201802.0.1](https://github.com/jonuts/GeriPsy/compare/201802.0...201802.0.1)
* HOTFIX - formatting for 90832 header

## [201802.0](https://github.com/jonuts/GeriPsy/compare/201801.0.3...201802.0)
* [Note changes](https://github.com/jonuts/GeriPsy/pull/117)
  - Dont display session minutes on treatment plans
  - Modify certification statements
* [Code Modifiers](https://github.com/jonuts/GeriPsy/pull/116) -
  Adds code modifiers for certain notes
* [9084x dup date rules](https://github.com/jonuts/GeriPsy/pull/115) -
  Allows 9084x and 9083x to be created with dup service dates

## [201801.0.3](https://github.com/jonuts/GeriPsy/compare/201801.0.2...201801.0.3)
* HOTFIX - adds session minutes to printouts

## 201801.0.2
* HOTFIX - update 90839 minimum time requirement

## 201801.0.1
* HOTFIX - need to handle encounters with old icd codes
         - patient pagination fix

## 201801.0
* [ICD Updates](https://github.com/jonuts/GeriPsy/pull/114) -
  New ICD10 list

## 201712.1
* [Note Changes](https://github.com/jonuts/GeriPsy/pull/113) -
  Printed text changes ; time limit update on 9084x

## 201712.0
* [Edit Primary Provider](https://github.com/jonuts/GeriPsy/pull/112) -
  Allow admin to update/view a patients 'primary' provider
* [Remit additions](https://github.com/jonuts/GeriPsy/pull/111) - Send
  remits w/o provider to admin

## 201711.1.1
* HOTFIX - fx bug introduced by Provider#hp\_account\_id

## 201711.1
* [Small fixes](https://github.com/jonuts/GeriPsy/pull/110)
* [Remit import](https://github.com/jonuts/GeriPsy/pull/109) - Accept,
  parse, import, and send out remits

## 201711.0.3
* HOTFIX - fixes bug in TP PDF export
         - adds missing fields from TP exports

## 201711.0.2
* HOTFIX - properly handle pre-gdr note exports

## 201711.0.1
* HOTFIX - missing GDR fields in exports

## 201711.0
* https://github.com/jonuts/GeriPsy/pull/108
* https://github.com/jonuts/GeriPsy/pull/107

## 201710.1
* https://github.com/jonuts/GeriPsy/pull/106

## 201710.0
* https://github.com/jonuts/GeriPsy/pull/105
* https://github.com/jonuts/GeriPsy/pull/104

## 201705.0
* https://github.com/jonuts/GeriPsy/pull/102
* https://github.com/jonuts/GeriPsy/pull/101
* https://github.com/jonuts/GeriPsy/pull/79
* https://github.com/jonuts/GeriPsy/pull/100
* https://github.com/jonuts/GeriPsy/pull/99
* https://github.com/jonuts/GeriPsy/pull/97
* https://github.com/jonuts/GeriPsy/pull/96
* https://github.com/jonuts/GeriPsy/pull/90
* https://github.com/jonuts/GeriPsy/pull/76
* https://github.com/jonuts/GeriPsy/pull/95
* https://github.com/jonuts/GeriPsy/pull/91
* https://github.com/jonuts/GeriPsy/pull/93
* https://github.com/jonuts/GeriPsy/pull/94
* https://github.com/jonuts/GeriPsy/pull/81
* https://github.com/jonuts/GeriPsy/pull/85
* https://github.com/jonuts/GeriPsy/pull/87
* https://github.com/jonuts/GeriPsy/pull/74
* https://github.com/jonuts/GeriPsy/pull/75
* https://github.com/jonuts/GeriPsy/pull/84
* https://github.com/jonuts/GeriPsy/pull/82
* https://github.com/jonuts/GeriPsy/pull/88

## 201702.2.2
* https://github.com/jonuts/GeriPsy/pull/83

## 201702.2
* https://github.com/jonuts/GeriPsy/pull/77
* https://github.com/jonuts/GeriPsy/pull/71
* https://github.com/jonuts/GeriPsy/pull/73
* https://github.com/jonuts/GeriPsy/pull/70
* https://github.com/jonuts/GeriPsy/pull/69
* https://github.com/jonuts/GeriPsy/pull/68
* https://github.com/jonuts/GeriPsy/pull/67
* https://github.com/jonuts/GeriPsy/pull/66
* https://github.com/jonuts/GeriPsy/pull/65
* https://github.com/jonuts/GeriPsy/pull/37
* https://github.com/jonuts/GeriPsy/pull/63
* https://github.com/jonuts/GeriPsy/pull/62
* https://github.com/jonuts/GeriPsy/pull/60
* https://github.com/jonuts/GeriPsy/pull/59
* https://github.com/jonuts/GeriPsy/pull/61
* https://github.com/jonuts/GeriPsy/pull/58

## 201702.1
* https://github.com/jonuts/GeriPsy/pull/55
* https://github.com/jonuts/GeriPsy/pull/54

## 201702.0
* https://github.com/jonuts/GeriPsy/pull/52
* https://github.com/jonuts/GeriPsy/pull/51
* https://github.com/jonuts/GeriPsy/pull/50

## 201701.2
* https://github.com/jonuts/GeriPsy/pull/49
* https://github.com/jonuts/GeriPsy/pull/47
* https://github.com/jonuts/GeriPsy/pull/46
* https://github.com/jonuts/GeriPsy/pull/45
* https://github.com/jonuts/GeriPsy/pull/42
* https://github.com/jonuts/GeriPsy/pull/44
* https://github.com/jonuts/GeriPsy/pull/43
* https://github.com/jonuts/GeriPsy/pull/41
* https://github.com/jonuts/GeriPsy/pull/40
* https://github.com/jonuts/GeriPsy/pull/8
* https://github.com/jonuts/GeriPsy/pull/39
* https://github.com/jonuts/GeriPsy/pull/38
* https://github.com/jonuts/GeriPsy/pull/36

## 201701.1
* https://github.com/jonuts/GeriPsy/pull/35
* https://github.com/jonuts/GeriPsy/pull/34
* https://github.com/jonuts/GeriPsy/pull/33
* https://github.com/jonuts/GeriPsy/pull/32
* https://github.com/jonuts/GeriPsy/pull/31
* https://github.com/jonuts/GeriPsy/pull/30
* https://github.com/jonuts/GeriPsy/pull/28
* https://github.com/jonuts/GeriPsy/pull/27
* https://github.com/jonuts/GeriPsy/pull/26
* https://github.com/jonuts/GeriPsy/pull/25

## 201701.0
* https://github.com/jonuts/GeriPsy/pull/24
* https://github.com/jonuts/GeriPsy/pull/23
* https://github.com/jonuts/GeriPsy/pull/22
* https://github.com/jonuts/GeriPsy/pull/19
* https://github.com/jonuts/GeriPsy/pull/20
* https://github.com/jonuts/GeriPsy/pull/21
* https://github.com/jonuts/GeriPsy/pull/18
* https://github.com/jonuts/GeriPsy/pull/17
* https://github.com/jonuts/GeriPsy/pull/16

## 201612.2
* https://github.com/jonuts/GeriPsy/pull/15
* https://github.com/jonuts/GeriPsy/pull/14
* https://github.com/jonuts/GeriPsy/pull/12
* https://github.com/jonuts/GeriPsy/pull/11
* https://github.com/jonuts/GeriPsy/pull/10
* https://github.com/jonuts/GeriPsy/pull/9
* https://github.com/jonuts/GeriPsy/pull/7

## 201612.1
* https://github.com/jonuts/GeriPsy/pull/6
* https://github.com/jonuts/GeriPsy/pull/5
* https://github.com/jonuts/GeriPsy/pull/4
* https://github.com/jonuts/GeriPsy/pull/3
* https://github.com/jonuts/GeriPsy/pull/2
