# PFA 放电回路调研：电极拓扑、单极/双极术语、回流电极极性、阻抗隔离与通路互锁

调研日期：2026-08-25。范围：已上市 PFA 导管电极拓扑、厂家「单极/双极」含义、体表回流电极极性、放电与测量/标测隔离、六瓣 1-3-5 vs 2-4-6 构型。检索对象限于厂家 IFU/规格书、FDA PMA/SSED、NMPA/CMDE 审评报告、期刊原文、IEC/GB 监管标准、ADI 数据手册与应用笔记。有一手证据的部分：FARAWAVE IFU 与 PMA P230030、PulseSelect PMA P230017 与 PULSED AF 原文、Sphere-9 PMA P240013 与厂家规格书、VARIPULSE PMA P240006、Globe PMA P240044 与厂家规格书、FARASTAR RSM 日文 IFU、Reddy 2018/2019、Stewart 2019（奇偶电极）、IEC 60601-2-2 与 GB 9706.202-2021、AD5941 数据手册与 AN-1557。空缺：国产六瓣花瓣导管厂家 IFU / CMDE 对电极编号与极性图的原文；商业 FARAPULSE 标签中「bipolar+unipolar pulse train」字样；回流垫接到发生器正极的一手资料；AD5941 用于千伏级放电隔离的厂家声明；六瓣 1-3-5 vs 2-4-6 作为固定两极的已上市 IFU。

下文先单独列出本项目已确认事实，再按 6 问写文献结论。二者不得混读。

---

## 本项目已确认事实（非文献）

以下仅来自本仓库项目共识，不作为行业证据：

- 导管：6 杆 × 4 杆电极 + 1 顶电极 = 25 位点。
- 1/3/5 杆电气连在一起，极性可选正/负；2/4/6 杆固定为负。
- 体表负极板 1 路，固定接到正极性；不接负极板仍可放电（双极）。
- 放电回路必须同时有正和负。
- 顶电极有独立控制继电器和独立极性选择。
- 回路继电器把 AD5941 测量前端接入/断开放电环，放电时必须断开。
- 同一电极同一时刻只接一条通路（放电/标测/回路测量/贴靠），硬件互斥。

---

## 摘要

已上市「花瓣/网篮」PFA 以 **FARAWAVE 五瓣 × 4 电极 = 20** 为代表，能量在导管电极之间以 **双极、双相** 波形交付，标签与 pivotal 研究均未要求体表回流垫。环形单次隔离导管（PulseSelect 9 电极、VARIPULSE 10 电极）同样是导管内双极。需要回流电极的是 **单极能量路径** 产品（Sphere-9 晶格头端对体表 return electrodes）。网状球阵（Globe 122 电极）厂家规格书写 bipolar, biphasic。厂家术语里 **bipolar/unipolar 首先指空间回路**（导管电极之间 vs 导管电极对皮肤垫），与波形的 **biphasic/monophasic（时间上极性翻转）** 不是同一轴；也与历史 RF 环形导管的「bipolar/unipolar 功率比」不是同一概念。商业 FARAPULSE 标签写的是 proprietary biphasic, bipolar waveform，**未找到**「bipolar+unipolar pulse train」作为该系统官方能量模式名称。中文「负极板」在国标中对应 **中性电极/返回电极**，描述的是回流功能而非瞬时电压极性；**未找到**回流垫接到发生器正极的一手资料。发生器侧对高压的隔离，公开 IFU 写的是 **放电时用继电器把标测/ECG 从患者断开**（FARASTAR RSM），以及放电结束后把消融电极改接到 EGM；ADI 对 AD5941 只声明皮肤/体阻抗测量及 IEC 60601 的 **隔直电容**，**不覆盖**千伏放电隔离。六瓣 1-3-5 vs 2-4-6 固定两极 **未在已上市 IFU 中找到**；最接近的一手构型是环形阵列上 **奇偶编号电极接相反极性**（猪模型，Stewart 2019）。

---

## 1. 已上市 PFA 导管电极拓扑

### 结论

花瓣/网篮形态的已上市代表是 **五瓣而非六瓣**：FARAWAVE 远端 5 条 spline、每条 4 电极，共 20 电极，可在 basket 与 flower 之间展开；五瓣在远端汇合，IFU 标有不透 X 线尖端，但放电电极计数为 20，未见独立「顶电极」作为第 21 路消融通道。环形单次隔离导管为 PulseSelect（9 金电极、25 mm 环）与 VARIPULSE（可变环、10 电极）。焦点/晶格导管 Sphere-9 是 **1 个 nitinol 晶格消融电极 + 9 个 mini 电极标测 + 2 环电极 + 1 中央参考电极**。网状球阵 Globe 为约 30 mm 球阵、122 电极，能量规格为 bipolar, biphasic。国产方面：NMPA 已批准德诺 CardiPulse 导管（国械注准 20243010461），但官方英文公示只写「导管 + 连接电缆」，**未找到**厂家 IFU 或 CMDE 审评报告原文给出六瓣电极编号/极性图；锦江发生器有 CMDE 审评报告，配套导管在公开结构描述中为环形远端（见未决）。**奇偶瓣作为两极**并非 FARAWAVE 的公开标签表述（五瓣无法均分成两组等量瓣）。

### 证据

**FARAPULSE / FARAWAVE（五瓣花瓣）**

- 厂家 IFU：导管为 over-the-wire 多电极，远端 **five splines with four electrodes located on each spline, twenty electrodes total**；部分展开为 basket，完全展开为 flower；规格 31 mm / 35 mm。[FARAWAVE IFU, Boston Scientific, 51622663-01A](https://www.bostonscientific.com/content/dam/elabeling/ep/pr/51622663-01A_FARAWAVE_IFU_EN_s.pdf)
- 较新 IFU（含 NAV）：同样 5 spline × 4 电极；放电后发生器自动把电极接到 EGM 连接器。[FARAWAVE NAV IFU, 51967706-01A](https://www.bostonscientific.com/content/dam/elabeling/ep/farawave/pulsed_fiel_ablation_catheter/farawave-nav_ifu-51967706/51967706-01A_FARAWAVE2-0-PERSAF_IFU_ML_s.pdf)
- FDA PMA **P230030**（2024-01-30 批准）：SSED 重复 5 splines、20 electrodes；发生器产生预定义高压脉冲波形。[FDA PMA P230030](https://www.accessdata.fda.gov/scripts/cdrh/cfdocs/cfpma/pma.cfm?id=P230030)；SSED 转载摘要见 [Innolitics P230030](https://fda.innolitics.com/device/P230030)
- 厂家规格书：输出为 **Proprietary FARAPULSE biphasic, bipolar waveform**。[FARAPULSE spec sheet](https://www.bostonscientific.com/content/dam/bostonscientific/ep/farapulse/farapulse-spec-sheet.pdf)
- 期刊：Reddy 等，导管 5 spline × 4 电极，全部电极用于消融，每瓣第 3 电极可记录电位；能量以 bipolar 方式跨电极交付。DOI: [10.1016/j.jacc.2019.04.021](https://doi.org/10.1016/j.jacc.2019.04.021)。CIRCEP 形态学研究再次确认 5 spline × 4 消融电极、2 kV bipolar biphasic，脉冲细节 proprietary。DOI: [10.1161/CIRCEP.124.013208](https://doi.org/10.1161/CIRCEP.124.013208)
- 中国注册：NMPA 英文公示 FARAWAVE / FARASTAR 获批进口（国械注进相关号见公开目录）。[NMPA 英文稿](https://english.nmpa.gov.cn/2025-02/19/c_1073560.htm)

**PulseSelect（环形 9 电极）**

- FDA PMA **P230017**（2023-12-13）：适应证含标测（刺激与记录）及阵发/持续房颤消融。[FDA PMA P230017](https://www.accessdata.fda.gov/scripts/cdrh/cfdocs/cfpma/pma.cfm?id=P230017)
- SSED：loop catheter 多电极，发生器交付 **bipolar, biphasic** 脉冲电场。[Innolitics P230017](https://fda.innolitics.com/device/P230017)
- 厂家规格：9 电极、环径 25 mm、电极长 3 mm、间距 3.75 mm。[PulseSelect catheter spec sheet](https://www.medtronic.com/content/dam/medtronic-wide/public/united-states/products/surgical-energy/ablation/cas-pulseselect-catheter-components-spec-sheet.pdf)
- 期刊：Verma 等 PULSED AF Pilot：9 金电极圆形阵列；**No external grounding patch was used due to the bipolar nature of the delivery.** DOI: [10.1161/CIRCEP.121.010168](https://doi.org/10.1161/CIRCEP.121.010168)
- CMDE 审评报告（进口发生器）：「设备可输出双极双相交变脉冲电场」。[CMDE PDF](https://www.cmde.org.cn/directory/web/cmde/images/1727058644826075008.pdf)

**VARIPULSE（可变环 10 电极）**

- FDA PMA **P240006**（2024-11-06）：FDA 公众页写导管尖端为 loop、**ten metal electrodes**。[FDA recently approved devices P240006](https://www.fda.gov/medical-devices/recently-approved-devices/varipulse-platform-varipulse-catheter-trupulse-generator-sterile-interface-cable-ngen-pump-p240006)
- SSED：circular loop、10 穿孔电极，用于标测（刺激/记录）并交付 **biphasic high-voltage pulses**。[Innolitics P240006](https://fda.innolitics.com/submissions/CV/CV-misc/QZI/P240006)

**Affera Sphere-9（晶格头端，非花瓣）**

- FDA PMA **P240013**（2024-10-24）。[FDA PMA P240013](https://www.accessdata.fda.gov/scripts/cdrh/cfdocs/cfpma/pma.cfm?id=P240013)
- 厂家规格书：1 lattice ablation electrode、9 mini electrodes、2 ring electrodes、1 central electrode；能量为 PF 与 RF；**Four return electrodes … IEC/EN 60601-2-2 are required for energy delivery.** Close-Unipolar 是标测商品名，不是放电回路名称。[Sphere-9 spec sheet](https://www.medtronic.com/content/dam/medtronic-wide/public/united-states/products/surgical-energy/ablation/cas-affera-sphere-9-spec-sheet.pdf)
- SSED：「To complete the electrical circuit for RF or PF energy delivery, the Ablation System requires the use of disposable return electrodes。」[Innolitics P240013](https://fda.innolitics.com/submissions/CV/CV-misc/QZI/P240013)
- 首个人体试验：晶格头可在 RF 与 PFA 间切换。DOI: [10.1161/CIRCEP.120.008718](https://doi.org/10.1161/CIRCEP.120.008718)

**Globe（球阵/网状，非六瓣花）**

- FDA PMA **P240044**（2025-08-27）。[FDA PMA P240044](https://www.accessdata.fda.gov/scripts/cdrh/cfdocs/cfpma/pma.cfm?id=P240044)
- 厂家规格书：spherical array、**122** 电极、电极选择最少 2 / 最多 64 路同时放电；**Electrode configuration: Bipolar, biphasic**。[Kardium Globe spec sheet](https://kardium.com/wp-content/uploads/2026/04/410-00004-EN-USA-Product-Spec-Sheet-1.pdf)
- SSED 图注含 rib（肋）与 electrode。[Innolitics P240044](https://fda.innolitics.com/device/P240044)
- 期刊（早期 RF/后续 PEF 描述）：30 mm 阵、16 ribs、122 电极。PMC: [PMC9872786](https://pmc.ncbi.nlm.nih.gov/articles/PMC9872786/)

**国产花瓣/环形**

- NMPA 英文公示：杭州德诺电生理「一次性使用心脏脉冲电场消融导管」获批，组成仅为 catheter and connecting cables，未写瓣数或极性。[NMPA](https://english.nmpa.gov.cn/2024-03/11/c_1049707.htm)（注册号公开渠道常见为国械注准 20243010461，本调研未下载到该证 PDF 原文。）
- 六瓣 × 每瓣 3 电极、网篮/花瓣切换等细节：仅见于商业转载，**未找到厂家 IFU PDF 或 CMDE 审评报告原文** → 记为未找到一手来源。
- 锦江 **LEAD-PFA** 发生器：CMDE 审评报告写主机经连接电缆把高压脉冲送到本公司一次性导管电极；未在该报告中给出花瓣拓扑或电极编号图。[CMDE](https://www.cmde.org.cn/directory/web/cmde/images/1704432933175055682.pdf)
- 惠泰相关：CMDE 审评报告写配套「一次性使用心脏脉冲电场消融导管为**环形导管**，用于肺静脉口和前庭消融」，申报产品本身为线性头端补充消融。[CMDE](https://www.cmde.org.cn/directory/web/cmde/images/1735781523430078349.pdf)

### 对本项目术语的启示（推论）

本项目 **6 杆 × 4 + 顶电极 = 25** 不是 FARAWAVE（20、无独立顶消融电极）的复制，也不是 Sphere-9 晶格单电极。更接近「多杆花瓣 + 独立尖端」的工程选择，公开已上市标签里没有同构对照。五瓣产品无法做成 1-3-5 vs 2-4-6 等量分组。

---

## 2. 厂家术语里的「单极 / 双极」指什么

### 结论

在 PFA 工程与已上市标签中，**bipolar（双极）= 高压加在导管上的电极（对或组）之间，不经过皮肤垫；unipolar/monopolar（单极）= 至少一路导管电极对贴在患者皮肤上的 patch/return electrode。** 这与「接不接负极板」是同一空间回路问题。另一轴是 **biphasic vs monophasic**：脉冲在时间上是否翻转极性，商业 FARAPULSE / PulseSelect 写的是 **biphasic + bipolar**。商业 FARAPULSE 的官方波形名称是 proprietary biphasic, bipolar waveform，**不是**「bipolar+unipolar pulse train」。该短语 **未在** FARAWAVE IFU、FARASTAR 规格书或 P230030 SSED 中找到。早期 Reddy 2018 写明 **no external patch is employed**。因此：**「不接负极板 = 双极」与 FARAPULSE 商业标签的 bipolar 是同一空间概念；与「bipolar+unipolar pulse train」不是已核实的同一官方术语。** 历史上 PVAC 射频的 2:1 bipolar/unipolar **功率比**（一部分能量走相邻电极，一部分走回流垫）是第三套用法，不可套到 FARAPULSE。

### 证据

**空间回路（导管间 vs 导管对垫）**

- Boston Scientific 工程师期刊综述（作者声明受雇于 BSC）：高压加在导管电极对/组之间称为 bipolar delivery；加在至少一个导管电极与皮肤 patch 之间称为 monopolar or unipolar delivery。DOI: [10.1111/pace.15120](https://doi.org/10.1111/pace.15120)
- PulseSelect 人体试验：因双极交付 **未使用** external grounding patch。DOI: [10.1161/CIRCEP.121.010168](https://doi.org/10.1161/CIRCEP.121.010168)
- Sphere-9：RF **或** PF 放电都需要 disposable return electrodes 闭合回路（PMA P240013 SSED，见上节 URL）。
- Reddy 2018（FARAWAVE 前身 Iowa Approach）：波形为 hierarchical millisecond pulses **in bipolar fashion across electrodes**；**no external patch is employed**。DOI: [10.1016/j.jacep.2018.04.005](https://doi.org/10.1016/j.jacep.2018.04.005)

**时间波形（双相 vs 单相）**

- Reddy 2019 IMPULSE/PEFCAT：治疗波形为跨电极的 bipolar 微秒级脉冲；方案从 **monophasic** 进化到 **biphasic**。DOI: [10.1016/j.jacc.2019.04.021](https://doi.org/10.1016/j.jacc.2019.04.021)
- FARASTAR 规格书：Proprietary FARAPULSE **biphasic, bipolar** waveform（见上节 spec sheet URL）。
- CMDE 对 PulseSelect：「双极双相交变脉冲电场」（见上节 CMDE PDF）。

**商业 FARAPULSE 是否使用「bipolar+unipolar pulse train」**

- 检索 FARAWAVE IFU、P230030 SSED、厂家规格书：**未找到**该短语。
- Heart Rhythm「How to」原文：电场以 bipolar fashion **between catheter electrodes** 施加，波形 biphasic，激活全部 5 spline、20 电极。DOI: [10.1016/j.hrthm.2024.06.058](https://doi.org/10.1016/j.hrthm.2024.06.058)

**易混淆的第三套用法：RF 环形导管的 bipolar/unipolar 比**

- Stewart 等用 PVAC GOLD + GENius：**Duty-cycled RF** 以 **2:1 bipolar/unipolar ratio** 同时向 9 电极送单极与双极射频；同一研究中 PFA 则为 **purely bipolar**，奇偶电极相反极性，**No energy was passed to a ground patch with PFA**。DOI: [10.1016/j.hrthm.2018.10.030](https://doi.org/10.1016/j.hrthm.2018.10.030)

**IEC 对高频手术（RF）的 monopolar/bipolar**（对照，非 PFA 专用）

- IEC 60601-2-2:2017：MONOPOLAR = 经 ACTIVE ELECTRODE 进入患者、经分开的 NEUTRAL ELECTRODE 返回；BIPOLAR 附件两电极均在术野、不需要 NE。标准样本：[IEC 60601-2-2:2017 样本](https://cdn.standards.iteh.ai/samples/22495/e21eb15864fc4ca4b4b8368c9e52eb65/IEC-60601-2-2-2017.pdf)

### 对本项目术语的启示（推论）

本项目「不接负极板仍可放电（双极）」与文献/标签中的 **PFA bipolar（导管内两极）** 对齐；接体表板则对应 **unipolar/monopolar 空间回路**（Sphere-9 一类）。不要把 FARAPULSE 的 **biphasic** 说成「单极+双极脉冲串」。若口头说「FARAPULSE 的 bipolar+unipolar」，目前没有该系统 IFU/PMA 一手支持，更可能是与 PVAC RF 功率比或与 monophasic/biphasic 的混淆。

---

## 3. 体表回流电极极性与中文「负极板」

### 结论

RF 与采用单极路径的 PFA（Sphere-9）都把体表大面积电极定义为 **中性/返回/分散电极（NE / return / dispersive / indifferent）**：作用是把电流以低电流密度送回发生器，避免烫伤。国标明确它还可俗称「负电极」。一手资料把垫接到发生器的 **NE / Indifferent / return 插座**，描述为回流路径，**不是**「接到发生器正极」。**未找到**任何 IFU、PMA 或 IEC/GB 条文写回流垫接到发生器正极。中文「负极板」是历史/口语对中性电极的叫法，**与脉冲瞬时极性无关**。本项目「负极板固定接到正极性」是项目硬件事实，与 RF/已上市单极 PFA 的公开接法不一致，不能用行业惯例解释。

### 证据

**监管定义（中性 ≠ 瞬时负极）**

- IEC 60601-2-2:2017 201.3.230 NEUTRAL ELECTRODE：为 MONOPOLAR 高频电流提供低电流密度回流；又称 plate、electrosurgical pad、passive、**return or dispersive electrode**。201.3.229 MONOPOLAR：经 ACTIVE ELECTRODE 施加、经 NE 返回（或经对地电容）。标准样本 URL 同上。
- GB 9706.202-2021（修改采用 IEC 60601-2-2:2017）201.3.230 中性电极：为高频电流单极应用提供低电流密度电气返回通道。**注 1：中性电极还可称为极板、电极板、电外科垫、负电极、返回电极或分散电极。** 公开扫描件：[GB 9706.202 文本摘录](https://yzvideo-c.yizimg.com/420549/2023915-111245649.pdf)

**厂家 IFU：接到「无关/返回」端子，不是正极**

- AtriCure nContact CS-3000 IFU：Indifferent, Dispersive Electrode「Commonly referred to as the return electrode or patient electrode or ground pad」；**connected to the generator at the Indifferent Connector**；提供电流经患者回到发生器的路径。[IFU-0022.B](https://www.atricure.com/sites/default/files/devices-ifu/IFU-0022.B.pdf)
- Abbott TactiCath SE IFU：消融需 RF generator、irrigation pump 与 **dispersive pad (indifferent patch electrode)**；故障提示含 indifferent electrode 贴敷不良。[Abbott eIFU ARTEN600077656_A](https://manuals.eifu.abbott/content/dam/av/manuals-eifu/global/US/en/ARTEN600077656_A.PDF)

**PFA 单极路径同样叫 return，未写正极**

- Sphere-9 规格书 / P240013 SSED：energy delivery 需要符合 IEC 60601-2-2 的 return electrodes（见第 1 节 URL）。未写接到发生器正极。
- PulseSelect / FARAWAVE 双极路径：**不使用** grounding patch（见第 2 节）。

**回流垫接到发生器正极**

- 按 IFU、PMA、IEC/GB 检索：**未找到一手来源。**

### 对本项目术语的启示（推论）

对外/注册材料若沿用「负极板」，建议同时给出标准名 **中性电极 / return electrode**，并写明本机把它接到放电回路的哪一极（项目事实：正极）。不要让读者以为国标「负电极」等于脉冲的负高压端。

---

## 4. 回路阻抗测量与高压放电隔离；AD5941 官方用途

### 结论

公开的已上市 PFA 系统把「保护测量/记录前端」写成：**放电瞬间用继电器把患者 ECG/诊断导管 EGM 从记录仪断开（blanking）**；消融导管电极在放电结束后再接到 EGM。Boston Scientific 综述还写发生器应在消融前测回路阻抗以设定电压，必要时在脉冲串间跟踪阻抗——但 **未给出继电器原理图，也未点名 AD5941**。ADI 对 AD5941 的官方用途是电化学与 **皮肤/体阻抗**；所谓 isolation capacitor 是为 IEC 60601 **隔断直流、限制微安级电流**，**不是**千伏放电隔离，数据手册也未声明可承受消融高压。用继电器在放电时把 AD5941 从放电环断开，是本项目硬件策略；**不能**从 ADI 文档推出芯片自身具备该隔离能力。

### 证据

**FARASTAR Recording System Module：继电器 blanking（厂家 IFU）**

- 日文 IFU：RSM 是患者与记录系统/ECG 之间的 **フィルタリング／保護ユニット**。主功能：PFA 施加期间把第三方 EP 记录系统输入从患者断开（诊断导管 EGM 与体表 ECG）。由发生器 STIM 连接器送来的同步信号 **'Blank'** 控制 **リレースイッチ**。默认通路模式：内部开关闭合，ECG/EGM 送到记录系统。放电前进入 blanking：EGM/ECG **从患者断开**，RSM 与记录系统侧短接以防噪声；放电结束后回到通路模式。[FARASTAR RSM IFU JP, 97271991-01A](https://www.bostonscientific.com/content/dam/elabeling/ep/csl/jp/97271991-01A_FARASTAR_IFU_JP_s.pdf)
- PMA P230030：RSM 适应证为 EP 实验室中、接在患者与记录/ECG 系统之间的 **filtering/protection unit**；发生器与 RSM 合用以减少消融时对记录系统的干扰。[Innolitics P230030](https://fda.innolitics.com/device/P230030)

**放电后把消融电极接到标测，而非同时测量**

- FARAWAVE IFU：能量交付后，FARASTAR **automatically routes** FARAWAVE 电极到 EGM Connector，供记录/标测系统观察。（IFU URL 见第 1 节）

**发生器应测阻抗（综述，非具体芯片）**

- Koop, PACE 2025：电路总阻抗影响送达组织的电压/电流；在安全电压电流上限确定后，**a pre-ablation measurement of the impedance should occur**；单极与双极测得的体阻抗可显著不同；局部阻抗在首串脉冲后可迅速变化，可在 PFA 期间测阻抗并调整电流。DOI: [10.1111/pace.15120](https://doi.org/10.1111/pace.15120)
- PulseSelect SSED 中的 **cord impedance** 出现在符合 IEC 60601-1 的安全性/规格审查条目，**不是**术中回路阻抗测量方法的描述。[Innolitics P230017](https://fda.innolitics.com/device/P230017)

**AD5941：官方用途不含高压隔离**

- 数据手册 Rev. G：Applications 为电化学测量、气体传感器、potentiostat，以及 **Bioimpedance: Skin impedance, Body impedance** 等；激励 DAC 幅度约 ±607 mV 量级；阻抗环路到 200 kHz。未出现消融、千伏、继电器互锁。[ADI AD5940/AD5941 Data Sheet](https://www.analog.com/media/en/technical-documentation/data-sheets/ad5940-5941.pdf)
- AN-1557：为符合 IEC 60601，人体最大直流约 10 µA；**isolation capacitors (CISOx) guarantee that no dc current enters the body**；另用 RLIMIT 限制电流。这是可穿戴生物阻抗的隔直/限流，不是高压隔离栅。[AN-1557](https://www.analog.com/en/resources/app-notes/an-1557.html)
- CN0565：4 线阻抗 + 0.47 µF 隔直电容；50 kHz 下 IEC 60601 交流限值量级为数百 µA。[CN0565](https://www.analog.com/en/resources/reference-designs/circuits-from-the-lab/CN0565.html)

**商业发生器用继电器把阻抗前端接入放电环、放电时断开**

- 按厂家 IFU / PMA 检索：**未找到**与本项目 AD5941+回路继电器同构的公开原理图。FARASTAR 公开的是保护 **记录仪**，不是保护阻抗 AFE。

### 对本项目术语的启示（推论）

本项目「放电前测、放电时继电器断开 AD5941」与 Koop 所述 **pre-ablation impedance** 以及 FARASTAR **放电时断开敏感前端** 在安全意图上同类，但实现对象不同（阻抗 AFE vs ECG/EGM）。AD5941 的「4-wire isolated」不可写成「耐高压隔离」。50 kHz 单频两点测阻抗与数据手册高带宽环路能力相容，仍须由板级继电器/爬电满足千伏隔离。

---

## 5. 标测 vs 消融通路切换与硬件互锁

### 结论

厂家 **会** 声明：高压与记录通道不能在同一时刻接到患者敏感输入。做法包括：(1) 放电时继电器 blanking（FARASTAR RSM）；(2) 专用隔离盒把发生器与 EP/EAM 隔离（Centauri Connect）；(3) 消融与起搏/感知 **不能同时激活**（AtriCure 510(k)）；(4) 导管 IFU 要求记录/刺激设备 **isolated**，漏电流限值。FARAWAVE 是 **时间复用**：放电后自动把同一组电极接到 EGM，而不是同时接高压与放大器。Sphere-9 SSED 列出导管延长线的 **DC isolation** 验证，但未展开「同一电极同时接标测放大器与消融高压」的禁令原文。未找到写明「禁止同一电极同时接标测放大器与消融高压」的逐字互锁条款覆盖所有厂家；已找到的是 **通路隔离/分时/模式互斥**。

### 证据

- FARAWAVE IFU：**Electrical recording or stimulation equipment must be isolated.** 心内电极所连设备漏电流不得超过 10 µA；连接设备须为 type CF、除颤防护、符合 IEC 60601-1。放电期间不要触碰患者。能量交付后发生器把电极改接到 EGM（见第 1、4 节 IFU URL）。
- FARASTAR RSM IFU：PFA 期间切断患者 ECG/EGM 至记录仪的路径（继电器，见第 4 节）。另警告：使用 FARAPULSE 时 ECG/EGM **必须经 RSM** 送入 EP 记录系统，以免损坏记录系统部件（同日文 IFU）。
- CardioFocus/Galvanize **Centauri Connect** 用户手册：将导管接到发生器以及 EAM 与 EP 记录放大器；**isolates the energy output of the Centauri Generator from the EP recording and EAM systems**。[LBL-00085-001 Rev K](https://files.cardiofocus.com/product-ifus-and-resources/LBL-00085-001%20Rev%20K%20-%20User%20Manual%20CENTAURI%20Connect%20GTI-00022-03_multilingual.pdf)
- AtriCure Isolator Transpolar Pen **K061593**：连接 ASU 时用于消融；经 ASB1 辅助口时可起搏/感知/记录；**The two modes of operation, ablation and pacing/sensing cannot be active at the same time.** [K061593 PDF](https://atricure.com/sites/default/files/pdf-doc/K061593_Isolator-Pen.pdf)
- EnSite Precision 说明书：GenConnect 把消融导管和体表分散电极接到放大器，**isolates the EnSite … location signal from being loaded by the ablation generator**（隔离标测定位信号与消融发生器负载，不是逐电极互锁的完整证明）。来源为 Abbott EnSite Precision 系统手册的第三方转载；**未在本次调研中打开 Abbott 现行 eIFU 原件**，该条仅作旁证，法庭级引用须核对厂家现行手册。
- Sphere-9 延长线验证含 **DC isolation**（P240013 SSED，见第 1 节）。规格书写 9 个 mini 电极用于 Close-Unipolar 标测、晶格电极用于 PF/RF 能量，暗示功能分离，但 **未找到**「禁止同一导体同时接两路」的 IFU 逐字句。

### 对本项目术语的启示（推论）

本项目「同一电极同一时刻只接一条通路（放电/标测/回路测量/贴靠）」比多数公开标签写得更硬、更细（含回路测量与贴靠）。行业公开证据支持 **放电时断开记录前端、模式互斥、分时复用同一电极**，足以作为互锁的安全理由，但不能声称「所有厂家 IFU 已用同一句式规定四通路硬件互斥」。

---

## 6. 六瓣 1-3-5 vs 2-4-6 是否为已知固定两极构型

### 结论

**未找到**已上市花瓣导管 IFU 或 PMA 给出「1-3-5 杆一组、2-4-6 杆一组、固定极性」的电极编号图。FARAWAVE 是 **五瓣**，公开描述为全部电极参与、在导管电极之间（有综述写 **相邻瓣之间**）形成双极场，细节 proprietary。环形 9 电极阵列的猪模型研究给出了可引用的 **奇偶电极相反极性、不走接地垫** 图，这是「隔电极分组」而非「隔瓣 1-3-5」。本项目 6 杆奇偶分组在公开已上市标签中 **没有直接同类**。

### 证据

**未找到的内容**

- FARAWAVE / PulseSelect / VARIPULSE / Sphere-9 / Globe 的 IFU 与 SSED：**无** 1-3-5 vs 2-4-6 spline 极性图。
- 国产六瓣 CardiPulse：**未找到**厂家 IFU 或 CMDE 报告中的电极编号与极性图（见第 1 节）。

**最接近的一手：环形阵列奇偶电极**

- Stewart 等，Heart Rhythm 2019：PFA 发生器经电缆把电极 **1, 3, 5, 7, … 接到一种极性，偶数电极接到相反极性**。正文：「All PFA deliveries were made in a purely bipolar manner, energizing all odd-numbered electrodes at one polarity while the even numbered electrodes were the opposite polarity (Figure 1A). No energy was passed to a ground patch with PFA。」图注：Odd-numbered electrodes one polarity, even-numbered the opposite. DOI: [10.1016/j.hrthm.2018.10.030](https://doi.org/10.1016/j.hrthm.2018.10.030)

**五瓣能量路径（非 1-3-5）**

- Reddy 2019：bipolar fashion **across electrodes**；发生器可编程 **bipolar electrode pairing options**，临床版本波形固定。DOI: [10.1016/j.jacc.2019.04.021](https://doi.org/10.1016/j.jacc.2019.04.021)；Reddy 2018 同样写 multiple channels, various bipolar electrode pairing options。DOI: [10.1016/j.jacep.2018.04.005](https://doi.org/10.1016/j.jacep.2018.04.005)
- 综述（KCCJ，引用 Reddy 等）：FARASTAR 输出 bipolar, biphasic pulses **applied between the adjacent splines**。该句来自综述而非 FARAWAVE IFU；IFU 未画相邻瓣极性图。DOI: [10.4070/kcj.2023.0023](https://doi.org/10.4070/kcj.2023.0023)
- CIRCEP 2024：pulse design and regional electric field **proprietary**。DOI: [10.1161/CIRCEP.124.013208](https://doi.org/10.1161/CIRCEP.124.013208)

**独立顶电极**

- FARAWAVE IFU：20 个 spline 电极 + radiopaque tip；未把 tip 列为第 21 路独立极性消融电极。
- Sphere-9：消融电极即晶格头端本身，对 return pad，不是「杆电极 + 顶电极」两套继电器。
- 本项目独立顶电极极性：**无已上市 IFU 对照。**

### 对本项目术语的启示（推论）

1-3-5 并联为一极、2-4-6 为另一极，在电路上类似 Stewart 的 **奇偶分组双极**，但是把「电极序号」换成了「杆序号」，且本项目允许 1-3-5 选正/负、并可选体表板作第三端。这是本机拓扑，不宜写成「FARAPULSE 标准接法」。五瓣产品 physically 无法做三对三的瓣间奇偶分组。

---

## 未决问题（文献盖不住，须问本项目硬件负责人）

1. **顶电极**在放电时默认并入哪一极、是否允许单独作为一极对 1-3-5 或 2-4-6 放电、不接顶电极时 24 位点是否仍满足「必须同时有正和负」。
2. **体表板接到正极性**的电路意图：是为了与 2-4-6（固定负）形成单极场，还是发生器输出级的极性定义与 IEC NE 相反？有无隔离变压器/H 桥使「正」仅为标签而非大地？
3. **不接负极板的双极**时，正负是否必须来自 1-3-5（若选正）对 2-4-6，顶电极如何参与？1-3-5 若也选负，如何从硬件上禁止无正极放电（项目规则：回路必须同时有正和负）。
4. **回路继电器**的耐压、爬电、与放电继电器的时序互锁（先断 AD5941 再合高压？故障时默认全断？）是否有硬件联锁还是仅固件。
5. **四通路互斥**（放电 / 标测 / 回路测量 / 贴靠）是每电极独立继电器矩阵，还是总线级切换；标测放大器是否经本板还是发生器/记录仪。
6. 国产对照导管若要对标，能否提供 **CardiPulse / 其他六瓣导管 IFU 或产品技术要求** 中的电极编号与极性图（公开渠道未找到）。
7. 测量激励是否可能经体表板闭合（单极测阻抗）还是仅在导管正负电极之间（与 REQ 的 2 电极、50 kHz 如何对应到 1-3-5 vs 2-4-6 vs 顶 vs 体表板）。
8. FARASTAR 类 **blanking 同步信号** 是否存在于本发生器（项目需求写测量仅放电前；触发源仍待硬件补充）。

---

## 主要一手来源一览

| 类型 | 标识 | URL 或 DOI |
|---|---|---|
| IFU | FARAWAVE 51622663-01A | https://www.bostonscientific.com/content/dam/elabeling/ep/pr/51622663-01A_FARAWAVE_IFU_EN_s.pdf |
| IFU | FARAWAVE NAV 51967706-01A | https://www.bostonscientific.com/content/dam/elabeling/ep/farawave/pulsed_fiel_ablation_catheter/farawave-nav_ifu-51967706/51967706-01A_FARAWAVE2-0-PERSAF_IFU_ML_s.pdf |
| IFU | FARASTAR RSM 日文 97271991-01A | https://www.bostonscientific.com/content/dam/elabeling/ep/csl/jp/97271991-01A_FARASTAR_IFU_JP_s.pdf |
| PMA | P230030 FARAPULSE | https://www.accessdata.fda.gov/scripts/cdrh/cfdocs/cfpma/pma.cfm?id=P230030 |
| PMA | P230017 PulseSelect | https://www.accessdata.fda.gov/scripts/cdrh/cfdocs/cfpma/pma.cfm?id=P230017 |
| PMA | P240013 Sphere-9 | https://www.accessdata.fda.gov/scripts/cdrh/cfdocs/cfpma/pma.cfm?id=P240013 |
| PMA | P240006 VARIPULSE | https://www.fda.gov/medical-devices/recently-approved-devices/varipulse-platform-varipulse-catheter-trupulse-generator-sterile-interface-cable-ngen-pump-p240006 |
| PMA | P240044 Globe | https://www.accessdata.fda.gov/scripts/cdrh/cfdocs/cfpma/pma.cfm?id=P240044 |
| 期刊 | Reddy 2018 | DOI 10.1016/j.jacep.2018.04.005 |
| 期刊 | Reddy 2019 | DOI 10.1016/j.jacc.2019.04.021 |
| 期刊 | Verma 2022 PULSED AF Pilot | DOI 10.1161/CIRCEP.121.010168 |
| 期刊 | Stewart 2019 | DOI 10.1016/j.hrthm.2018.10.030 |
| 期刊 | Koop 2025 | DOI 10.1111/pace.15120 |
| 标准 | IEC 60601-2-2:2017 | 见正文样本 URL |
| 标准 | GB 9706.202-2021 | 见正文摘录 URL |
| 数据手册 | AD5940/AD5941 Rev. G | https://www.analog.com/media/en/technical-documentation/data-sheets/ad5940-5941.pdf |
| 应用笔记 | AN-1557 | https://www.analog.com/en/resources/app-notes/an-1557.html |
| 监管 | NMPA CardiPulse 公示 | https://english.nmpa.gov.cn/2024-03/11/c_1049707.htm |
| 监管 | CMDE 锦江 LEAD-PFA | https://www.cmde.org.cn/directory/web/cmde/images/1704432933175055682.pdf |
| 监管 | CMDE PulseSelect 进口 | https://www.cmde.org.cn/directory/web/cmde/images/1727058644826075008.pdf |
