# 公开数据来源与适用范围

当前概率数据版本为 `2026.07-public-v3`。代码中的来源清单位于
`lib/data/probability_sources.dart`，本页记录每个公开事实如何进入模型，以及它不能代表什么。

## FIFA 公开资料

| 来源 | 公开事实 | 在项目中的用途 | 限制 |
| --- | --- | --- | --- |
| [FIFA Professional Football Report 2023](https://inside.fifa.com/legal/news/fifa-publishes-professional-football-report-2023) | 128,694 名男子职业球员、3,986 家俱乐部，覆盖 135 个国家；逐洲主要协会人数和本土球员比例 | 按协会注册人数绘制扇区，并条件抽取本土/外籍球员 | 协会注册人数不是球员国籍；报告只逐项列出各洲前五（OFC 仅两项） |
| [FIFA Club World Cup 2025 clubs](https://www.fifa.com/en/articles/draw-procedures-confirmed) | 2025 年赛事 32 支参赛俱乐部 | 当前真实俱乐部基础目录，供随机与人生模拟使用 | 是全球顶级赛事样本，不是所有职业俱乐部数据库 |
| [FIFA Club World Cup 2025 squad lists](https://www.fifa.com/en/tournaments/mens/club-world-cup/usa-2025/articles/world-cup-winners-fcwc25-usa-lionel-messi-neuer-griezmann) | 官方表逐项列出 81 个国籍，包括巴西 141、阿根廷 103、西班牙 54、葡萄牙 49、墨西哥 41、美国 40 等 | 先按洲足联聚合人数，再在洲内按具体国家人数绘制扇区 | 这是洲际代表俱乐部的精英样本，不代表全球所有职业球员 |
| [FIFA Men’s January transfer snapshot 2025](https://inside.fifa.com/transfer-system/transfer-reports?tab=Men%27s+January+transfer+snapshot+2025) | 5,863 笔男子职业国际转会；平均年龄 24.9 岁；17.7% 涉及转会费 | 转会年龄中心值、有偿转会比例与转会类型关系 | 只覆盖国际转会，不能代表同协会内部转会 |
| [FIFA Transfer Reports Methodology](https://inside.fifa.com/transfer-system/transfer-reports/methodology) | 统计 11 人制职业球员的国际转会，交易由俱乐部和协会通过 TMS 提交 | 限定转会概率的适用范围 | 不是完整的球员职业履历数据库 |

## 专业球员网站的字段类型

项目参考公开的 [Transfermarkt 球员资料页](https://www.transfermarkt.com/eder-militao/profil/spieler/401530)
和[详细表现页](https://www.transfermarkt.com/jumplist/leistungsdaten/spieler/398184)
设计档案字段。参考的数据种类包括：

- 姓名、出生日期、出生地、身高、公民身份、惯用脚；
- 主位置、其他位置、球衣号码、青训经历；
- 当前俱乐部、加盟日期、合同到期、经纪人；
- 国家队、国家队首秀、出场和进球；
- 转会流水、转会类型和费用；
- 伤病类型、缺阵天数和错过比赛；
- 按年龄记录的身价轨迹；
- 按赛季、俱乐部和赛事拆分的出场、进球、助攻、牌数与累计分钟。

Transfermarkt 在本项目中只用于确定现代职业球员资料页常见的字段体系。项目不抓取其数据库，
也不把模拟身价表示为 Transfermarkt 的真实或官方估值。

## 精确值、校准值与纯建模值

### 直接使用的公开值

- 全球 128,694 名男子职业球员；
- 报告逐项列出的 27 个协会人数，以及由全球总数减出的 62,992 人尾部桶；
- 世俱杯精英样本中完整 81 个国籍人数，以及由这些人数汇总出的六个洲足联权重；
- 2025 年 1 月男子国际转会平均年龄 24.9 岁；
- 2025 年 1 月男子国际转会中 17.7% 涉及费用；
- 2023 年全球男子职业球员和俱乐部数量级。

### 根据公开关系完成的模型

- 转会类型权重为自由转会 62、租借 20、永久转会 18。18 对齐公开的有偿转会比例；
  62 和 20 用来表达“自由球员占多数、其余主要为租借”的公开关系，不是 FIFA 发布的精确百分比。
- 转会年龄围绕 24.9 岁抽样，并受首秀和退役年龄约束；它是校准后的生成分布，
  不是对原始 TMS 记录的复刻。

### 当前仍为产品建模的概率

位置、惯用脚、青训等级、转会次数、合同长度、伤病类型、成长曲线、比赛效率和冠军概率
目前没有混用来源不一致的网络百分比，而是保留显式、可测试的产品权重。
在获得覆盖范围一致且可授权使用的数据集前，界面和文档不应把这些项目标为全球真实概率。

## 更新规则

更新概率表时必须：

1. 修改 `ProbabilitySources.dataVersion`；
2. 保存来源 URL、发布日期、样本范围和应用字段；
3. 区分公开原值、派生值和产品建模值；
4. 运行固定种子、边界、聚合一致性和概率表测试；
5. 对用户可见的统计口径同步更新本页。
