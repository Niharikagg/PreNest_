import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../stage/stage.dart';
import '../stage/stage_provider.dart';

/// Presentation and content model for source-linked health guides.
class GuideArticle {
  final String id;
  final String title;
  final String
  category; // 'Period & PCOS', 'Planning', 'Pregnancy', 'Postpartum', 'Partner'
  final String readTimeLabel;
  final String sourceLabel;
  final String summary;
  final List<String> keyTakeaways;
  final String body;

  const GuideArticle({
    required this.id,
    required this.title,
    required this.category,
    required this.readTimeLabel,
    required this.sourceLabel,
    required this.summary,
    required this.keyTakeaways,
    required this.body,
  });
}

const List<GuideArticle> kSeedGuideArticles = [
  GuideArticle(
    id: 'pregnancy_nutrition_indian',
    title: 'Indian Pregnancy Nutrition & Trimester Meal Ideas',
    category: 'Pregnancy',
    readTimeLabel: '5 min read',
    sourceLabel: 'ICMR-NIN & MoHFW India',
    summary: 'Practical balanced Indian meal planning across trimesters featuring vegetarian and non-vegetarian protein sources, folates, and essential micronutrients.',
    keyTakeaways: [
      'Trimester 1 focuses on nutrient density (folate, vitamin B6) rather than heavy calorie increases.',
      'Combine legumes and cereals (e.g. moong dal khichdi, idli-sambar) to achieve complete plant-based amino acid profiles.',
      'Vegetarians: prioritize paneer, curd, sprouted moong, besan chilla, and roasted chana for daily protein.',
      'Non-vegetarians: opt for well-cooked eggs and low-mercury fresh fish (e.g., rohu, katla); avoid raw or undercooked items.',
      'Avoid unpasteurized dairy, raw unripe papaya, and excess refined sugar or ultra-processed snacks.',
    ],
    body:
        'Nutrition during pregnancy is about eating nutrient-rich foods rather than "eating for two." According to the Indian Council of Medical Research - National Institute of Nutrition (ICMR-NIN), a pregnant woman needs an additional 350 kcal/day in the second and third trimesters, with a substantial requirement for protein, bioavailable iron, calcium, and folate.\n\n'
        '1. First Trimester (Weeks 1–12):\n'
        'Focus on mitigating nausea with small, frequent meals. Light carbohydrates like roasted poha, puffed rice (murmura), and ginger-lemon tea help settle stomach discomfort. Folic acid (400 mcg daily) remains paramount for fetal neural tube closure.\n\n'
        '2. Second Trimester (Weeks 13–27):\n'
        'Fetal skeletal development accelerates. Incorporate calcium-rich options like ragi (finger millet) porridge, curd, and paneer alongside vitamin D exposure. Add daily leafy greens like palak and methi to support maternal blood volume expansion.\n\n'
        '3. Third Trimester (Weeks 28–40):\n'
        'Fetal brain growth and fat stores peak. Emphasize omega-3 fatty acids (walnuts, flaxseed powder, or doctor-approved fish oil), fiber-dense lentils, and plenty of fluids to prevent constipation and hemorrhoids.\n\n'
        'Always consult your obstetrician before taking any herbal remedies or changing prescribed supplements.',
  ),
  GuideArticle(
    id: 'iron_rich_indian_meals',
    title: 'Iron-Rich Indian Meals to Support Haemoglobin',
    category: 'Pregnancy',
    readTimeLabel: '4 min read',
    sourceLabel: 'MoHFW India (Anemia Mukt Bharat)',
    summary: 'How to naturally combat maternal anemia through traditional Indian foods and the vital rule of pairing plant-based iron with Vitamin C.',
    keyTakeaways: [
      'Plant-based (non-heme) iron in palak, methi, chana, and ragi requires Vitamin C for optimal absorption.',
      'Always squeeze fresh lemon or have amla, guava, or tomatoes alongside your dal and sabzi.',
      'Never consume tea or coffee within 1 hour before or after meals, as tannins strongly inhibit iron uptake.',
      'Take your prescribed Iron & Folic Acid (IFA) tablet with plain water or citrus juice—never with milk or calcium pills.',
    ],
    body:
        'Nutritional anemia is highly prevalent in expectant mothers across India. Under the National Health Mission\'s Anemia Mukt Bharat initiative, preventing maternal hemoglobin drops below 11 g/dL is crucial to reducing low birth weight and maternal fatigue.\n\n'
        'Maximizing Plant-Based Iron:\n'
        'While vegetarian staples like black chana, rajma, bajra, ragi, and leafy greens are rich in iron, they contain non-heme iron which is bound by phytates. Adding Vitamin C (such as a squeeze of fresh nimbu on your dal, a side of amla chutney, or sliced capsicum) converts iron into a highly soluble form that the intestinal lining absorbs up to 300% more effectively.\n\n'
        'The Chai & Calcium Rule:\n'
        'Tannins in Indian chai and polyphenols in coffee bind to iron molecules, flushing them out unabsorbed. Similarly, calcium competes directly with iron at cellular absorption sites. Always space your milk, calcium tablets, and tea at least two hours away from iron supplements and iron-rich meals.\n\n'
        'Cooking in Traditional Cast Iron:\n'
        'Simmering curries and dals in an iron kadhai has been shown to naturally enrich foods with trace bioavailable iron. Ensure you do not store sour or highly acidic foods in cast iron for prolonged hours.',
  ),
  GuideArticle(
    id: 'anc_visit_checklist',
    title: 'What to Bring to Your Next ANC Visit',
    category: 'Pregnancy',
    readTimeLabel: '3 min read',
    sourceLabel: 'MoHFW & WHO Guidelines',
    summary: 'Essential preparation checklist for your routine Antenatal Care (ANC) consultations under Government of India and WHO protocols.',
    keyTakeaways: [
      'Always carry your Mother and Child Protection (MCP) card and previous scan films in a water-resistant folder.',
      'Bring all current prescription slips, iron/calcium supplements, and recent urine/blood reports.',
      'Maintain a written list of symptoms, kicks, or questions so you don\'t forget during the consultation.',
      'Check your BP and weight at every visit; ask about your fundal height and baby\'s fetal heart rate.',
    ],
    body:
        'Antenatal Care (ANC) visits are vital health checks designed to identify and manage potential pregnancy complications early. Under India\'s Pradhan Mantri Surakshit Matritva Abhiyan (PMSMA), every pregnant woman is entitled to comprehensive checkups on the 9th of every month.\n\n'
        'Your ANC Travel Folder Checklist:\n'
        '1. Mother and Child Protection (MCP) Card: This is your universal maternal identity document across public and private hospitals.\n'
        '2. Previous Ultrasound & Doppler Reports: Keep chronological files of your dating scan, NT scan (11–13 weeks), and anomaly scan (18–20 weeks).\n'
        '3. Lab Reports: Hemoglobin, blood grouping (Rh status), urine albumin/sugar, OGTT glucose tolerance, and thyroid (TSH).\n'
        '4. Current Medications & Doses: Bring the actual strips of your IFA, calcium, and gestational vitamins.\n\n'
        'Questions to Ask Your Doctor:\n'
        '• "Is my blood pressure in the normal range today?"\n'
        '• "Is the baby\'s growth corresponding well to my gestational age?"\n'
        '• "Are there any specific warning signs I should watch for over the next 4 weeks?"',
  ),
  GuideArticle(
    id: 'male_fertility_preconception',
    title: 'Male Fertility & Preconception Tips (For Him)',
    category: 'Partner',
    readTimeLabel: '4 min read',
    sourceLabel: 'WHO & ACOG Clinical Guidelines',
    summary: 'Non-blaming, evidence-backed lifestyle and nutritional guidance for the male partner during the crucial preconception window.',
    keyTakeaways: [
      'Sperm spermatogenesis takes approximately 72 to 90 days; lifestyle choices today shape sperm health 3 months later.',
      'Avoid scrotal overheating: keep laptops off laps, avoid frequent hot water baths, and choose breathable cotton underwear.',
      'Eliminating smoking, gutkha/tobacco chewing, and excessive alcohol dramatically improves sperm DNA integrity.',
      'Eat antioxidant-rich foods: walnuts, pumpkin seeds (zinc), tomatoes (lycopene), and dark leafy greens.',
    ],
    body:
        'Conception is a shared 50/50 biological journey. Approximately half of all conception delays involve paternal factors such as sperm count, motility, or morphology. Because new sperm cells take nearly 3 months to fully mature, adopting healthy habits well ahead of trying pays massive dividends.\n\n'
        '1. Temperature Regulation:\n'
        'Testicular tissue functions best at 2 to 3°C below core body temperature. Resting warm laptops directly on your lap, prolonged cycling without breaks, or taking scalding hot showers can elevate scrotal temperatures and suppress sperm production.\n\n'
        '2. Micronutrients for Sperm Health:\n'
        '• Zinc: Crucial for testosterone synthesis and sperm motility. Found abundantly in pumpkin seeds, lentils, chickpeas, and eggs.\n'
        '• Lycopene: A potent antioxidant found in cooked tomatoes and watermelon that protects sperm cells from oxidative stress.\n'
        '• Folate: Essential for paternal DNA replication. Dark green vegetables and legumes support healthy chromosomes.\n\n'
        '3. Mental Stress & Sleep:\n'
        'Chronic workplace stress and sleep deprivation elevate cortisol, which down-regulates testosterone. Prioritize 7 to 8 hours of restorative sleep together as a couple.',
  ),
  GuideArticle(
    id: 'pcod_pcos_low_gi',
    title: 'Understanding PCOD/PCOS & Low-GI Indian Habits',
    category: 'Period & PCOS',
    readTimeLabel: '5 min read',
    sourceLabel: 'ICMR & Endocrine Society',
    summary: 'Demystifying insulin resistance in Polycystic Ovary Syndrome and building sustainable, low-glycemic traditional Indian food routines.',
    keyTakeaways: [
      'PCOS is primarily a metabolic condition driven by insulin resistance, not merely an ovarian disorder.',
      'Swap high-GI refined grains (maida, polished white rice) with whole millets (ragi, jowar, foxtail) and steel-cut oats.',
      'Eat vegetables and protein first before carbohydrates to blunt post-meal glucose and insulin spikes.',
      'A consistent 30-minute daily walk or resistance exercise significantly improves ovulation regularity.',
    ],
    body:
        'Polycystic Ovary Syndrome (PCOS) affects an estimated 1 in 5 Indian women of reproductive age. In the majority of cases, high circulating insulin levels stimulate the ovaries to produce excess androgens, leading to delayed ovulation, irregular cycles, acne, and stubborn weight gain.\n\n'
        'The Low-Glycemic Index (Low-GI) Strategy:\n'
        'When you consume high-GI foods like white bread, polished rice, or sugary sweets, blood sugar rises sharply, triggering large surges of insulin. Replacing these with traditional Indian complex carbohydrates stabilizes insulin:\n'
        '• Incorporate whole millets: Jowar, bajra, and ragi rotis contain resistant starches that digest slowly.\n'
        '• The "Plate Order" Hack: Start your meal with a raw salad (cucumber, carrots, tomato) and dal/paneer before touching your roti or rice. Fiber and protein slow gastric emptying, preventing glucose spikes.\n\n'
        'Daily Movement & Sleep Consistency:\n'
        'Muscle contraction pulls glucose out of the bloodstream independently of insulin. Just 20 to 30 minutes of moderate brisk walking or strength training improves insulin sensitivity. Sleeping at regular hours regulates the circadian rhythm of reproductive hormones.',
  ),
  GuideArticle(
    id: 'postpartum_recovery_breastfeeding',
    title: 'Postpartum Recovery & Breastfeeding Basics',
    category: 'Postpartum',
    readTimeLabel: '5 min read',
    sourceLabel: 'WHO & MoHFW India',
    summary: 'Navigating the critical first weeks: colostrum benefits, early latching, maternal tissue healing, and setting realistic fourth-trimester expectations.',
    keyTakeaways: [
      'Colostrum is thick, concentrated "liquid gold" perfectly suited for a newborn\'s marble-sized stomach on day 1.',
      'Initiate skin-to-skin contact within the first hour of birth to stimulate hormonal bonding and natural latching.',
      'Rest horizontally when baby sleeps; physical healing and uterine involution require reduced downward pelvic pressure.',
      'Hydrate with warm fluids and lean on your partner and family for burping, soothing, and household support.',
    ],
    body:
        'The "fourth trimester" represents profound physical and emotional adaptation for mother and baby. Immediate post-birth focus should center on gentle recovery, nourishment, and establishing lactation.\n\n'
        '1. The Magic of Colostrum:\n'
        'During the first 2 to 4 days, your breasts produce colostrum—a golden, thick fluid packed with secretory antibodies (IgA), proteins, and protective white blood cells. Newborns only need a few teaspoons per feeding because their stomachs are the size of a marble.\n\n'
        '2. Latching Comfort & Position:\n'
        'Painless feeding requires an asymmetric latch. Position baby tummy-to-tummy with their chin touching your breast and nose clear. Encourage a wide yawn-like mouth opening so baby draws in a generous portion of the lower areola.\n\n'
        '3. Maternal Recovery Tips:\n'
        '• Vaginal Delivery: Use warm water rinse bottles after urination and take gentle warm sitz baths for perineal comfort.\n'
        '• C-Section: Keep the surgical incision completely dry and clean. Avoid lifting anything heavier than your baby for 4 to 6 weeks.\n\n'
        'If nipple pain persists beyond the initial seconds of latch, consult a certified lactation consultant promptly.',
  ),
  GuideArticle(
    id: 'danger_signs_108',
    title: 'Knowing Pregnancy Danger Signs & When to Call 108',
    category: 'Pregnancy',
    readTimeLabel: '4 min read',
    sourceLabel: 'MoHFW India & WHO Guidelines',
    summary: 'Critical triage guide explaining maternal emergency signs that require immediate transport to an emergency obstetric care facility.',
    keyTakeaways: [
      'Heavy vaginal bleeding (soaking a sanitary pad in under 1 hour) is an immediate medical emergency.',
      'Severe, persistent headache with flashing lights or blurred vision indicates impending eclampsia.',
      'Sudden drop in baby movements or fits/convulsions requires immediate 108 ambulance dispatch.',
      'Dial 108 (free 24/7 National Ambulance Service across Indian states) without delay.',
    ],
    body:
        'While pregnancy is a natural physiological process, certain acute symptoms demand immediate emergency evaluation. Under Indian public health guidelines, recognizing these danger signs early prevents severe complications.\n\n'
        'CRITICAL RED-FLAG DANGER SIGNS:\n'
        '1. Heavy Vaginal Bleeding: Passing large clots or soaking through a menstrual pad in under an hour may indicate placental abruption or previa.\n'
        '2. Severe Headache with Visual Changes: Pounding front-of-head pain, blurred vision, or seeing spots/flashes is a sign of acute preeclampsia or impending eclampsia.\n'
        '3. Fits or Seizures / Convulsions: Uncontrolled shaking or loss of consciousness is an acute obstetric emergency.\n'
        '4. Sudden Drop in Fetal Movements: If you feel fewer than 10 kicks over a 2-hour quiet rest period in the third trimester, visit the hospital for CTG monitoring immediately.\n'
        '5. High Fever & Rigors: Temperature over 101°F with shivering can point to intra-uterine infection or sepsis.\n'
        '6. Fluid Trickling or Gush: Water breaking prematurely (PROM) requires sterile evaluation to prevent fetal infection.\n\n'
        'In any of these emergencies, dial 108 immediately. Have your MCP card, hospital bag, and emergency contacts ready.',
  ),
  GuideArticle(
    id: 'folic_acid_preconception',
    title: 'Preconception Checklist & Folic Acid Importance',
    category: 'Planning',
    readTimeLabel: '4 min read',
    sourceLabel: 'ICMR-NIN & WHO Guidelines',
    summary: 'Why starting 400 mcg folic acid at least 3 months prior to conception prevents neural tube defects, and essential preconception health checks.',
    keyTakeaways: [
      'The baby\'s neural tube closes within the first 28 days of pregnancy, often before a missed period is confirmed.',
      'Taking 400 mcg folic acid daily reduces neural tube defect risk by up to 70%.',
      'Check baseline hemoglobin, thyroid (TSH), rubella IgG, and blood group (Rh factor) preconception.',
      'Review existing chronic medications with your physician prior to discontinuing contraception.',
    ],
    body:
        'The healthiest pregnancies begin before conception. Preconception health planning allows you and your healthcare provider to optimize physical health, review genetics, and correct nutritional baselines.\n\n'
        'The Folic Acid Imperative:\n'
        'The neural tube—which develops into the baby\'s brain and spinal cord—closes completely within 28 days following fertilization. Because many pregnancies are unplanned or recognized after 5–6 weeks, international health bodies recommend that all women planning a pregnancy consume 400 mcg of folic acid daily for at least 3 months prior to conception.\n\n'
        'Essential Preconception Clinical Tests:\n'
        '• Complete Blood Count (CBC): Identifies underlying anemia or thalassemia trait.\n'
        '• Thyroid Profile (TSH): Maternal thyroid balance is critical for early fetal neurodevelopment.\n'
        '• Blood Group & Rh Typing: Flags potential Rh incompatibility for proactive management.\n'
        '• Rubella & Hepatitis B Immunity: Ensures vaccination protection prior to conception.\n\n'
        'Schedule a preconception consultation with your gynecologist to review current medications and family medical history.',
  ),
  GuideArticle(
    id: 'postpartum_mental_health',
    title: 'Fourth Trimester Emotional Wellbeing & Tele-MANAS',
    category: 'Postpartum',
    readTimeLabel: '4 min read',
    sourceLabel: 'MoHFW Tele-MANAS & WHO',
    summary: 'Distinguishing normal "baby blues" from postpartum depression, and accessing free, 24/7 confidential mental healthcare in India.',
    keyTakeaways: [
      '"Baby blues" (tearfulness, mood swings) affect up to 80% of mothers and usually resolve by day 10 to 14.',
      'Postpartum depression or anxiety persisting past 2 weeks is a treatable medical condition, not a personal failure.',
      'The Government of India\'s Tele-MANAS helpline (14416 or 1800-891-4416) is free, 24/7, and available in regional languages.',
      'Partners play a vital role by validating feelings, ensuring sleep, and encouraging medical checkups without judgment.',
    ],
    body:
        'Childbirth triggers profound hormonal, neurological, and social shifts. While society often expects immediate bliss, feelings of exhaustion, anxiety, and tearfulness are exceedingly common.\n\n'
        'Baby Blues vs. Postpartum Depression (PPD):\n'
        '• Baby Blues: Driven by sudden drops in estrogen and progesterone. Manifests as crying spells, irritability, and vulnerability. Typically peaks around day 3–5 and fades by 2 weeks with rest.\n'
        '• Postpartum Depression (PPD): Symptoms persist beyond 2 weeks, including intense guilt, numbness, difficulty bonding with baby, severe insomnia even when baby sleeps, or intrusive thoughts. PPD requires compassionate medical support.\n\n'
        'Support via Tele-MANAS (14416):\n'
        'The Ministry of Health & Family Welfare operates Tele-MANAS—a 24/7 free mental health tele-counselling network across India. You can connect with certified counsellors in Hindi, Kannada, Tamil, Telugu, Marathi, Bengali, and English with zero stigma.\n\n'
        'Speak to your obstetrician or family physician; effective, nursing-safe therapies are available.',
  ),
  GuideArticle(
    id: 'partner_labor_support',
    title: 'Partner Guide: Supporting Labour, Birth & Early Days',
    category: 'Partner',
    readTimeLabel: '4 min read',
    sourceLabel: 'ACOG & UNICEF Guidance',
    summary: 'Concrete, actionable ways the non-birthing partner can advocate, provide comfort, and share infant duties seamlessly.',
    keyTakeaways: [
      'Master the 5-1-1 rule: contractions 5 min apart, lasting 1 min, for at least 1 hour before heading to hospital.',
      'Pack the hospital bag in advance: MCP card, government ID cards, loose clothing, and newborn essentials.',
      'Offer continuous physical support: counter-pressure on lower back, sips of water, and affirming words.',
      'Post-birth: own diaper changes, swaddling, burping, and soothing so mom can sleep uninterrupted.',
    ],
    body:
        'Partners often feel unsure of their role during labor and the early weeks. Research confirms that continuous, loving partner presence reduces maternal anxiety and improves the birthing experience.\n\n'
        'During Labor:\n'
        '1. Time Contractions Accurately: Use PreNest\'s Contraction Timer. When contractions are 5 minutes apart, lasting 1 minute each, consistently over 1 hour (the 5-1-1 rule), it is time to move to the hospital.\n'
        '2. Comfort Measures: Firm sacral counter-pressure with your palm during active contractions relieves lower back tension. Offer ice chips or sips of water between contractions.\n'
        '3. Advocate Gently: Know her birth plan preferences and assist in communicating them respectfully to the medical team.\n\n'
        'During the Early Postpartum Days:\n'
        'The most effective partner support is practical. Take charge of burping, diapering, skin-to-skin soothing, and washing pump parts so the birthing mother can achieve 2 to 3-hour stretches of uninterrupted recovery sleep.',
  ),
];

class GuidesState {
  final String selectedCategory; // 'All', 'For You', 'Period & PCOS', 'Planning', 'Pregnancy', 'Postpartum', 'Partner'
  final String searchQuery;
  final List<GuideArticle> articles;

  const GuidesState({
    this.selectedCategory = 'All',
    this.searchQuery = '',
    this.articles = kSeedGuideArticles,
  });

  GuidesState copyWith({
    String? selectedCategory,
    String? searchQuery,
    List<GuideArticle>? articles,
  }) {
    return GuidesState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      articles: articles ?? this.articles,
    );
  }
}

class GuidesNotifier extends Notifier<GuidesState> {
  @override
  GuidesState build() {
    return const GuidesState();
  }

  void setCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

final guidesProvider = NotifierProvider<GuidesNotifier, GuidesState>(() {
  return GuidesNotifier();
});

/// Computes filtered articles based on search query, category, and active pregnancy stage.
final filteredArticlesProvider = Provider<List<GuideArticle>>((ref) {
  final state = ref.watch(guidesProvider);
  final currentStage = ref.watch(stageProvider);

  return state.articles.where((article) {
    // 1. Search Query Filter
    if (state.searchQuery.trim().isNotEmpty) {
      final q = state.searchQuery.trim().toLowerCase();
      final inTitle = article.title.toLowerCase().contains(q);
      final inSummary = article.summary.toLowerCase().contains(q);
      final inBody = article.body.toLowerCase().contains(q);
      final inTakeaways = article.keyTakeaways.any(
        (t) => t.toLowerCase().contains(q),
      );
      final inSource = article.sourceLabel.toLowerCase().contains(q);
      if (!inTitle && !inSummary && !inBody && !inTakeaways && !inSource) {
        return false;
      }
    }

    // 2. Category Filter
    if (state.selectedCategory == 'All') {
      return true;
    }

    if (state.selectedCategory == 'For You') {
      // Map current user stage to article categories
      switch (currentStage) {
        case PregnancyStage.plan:
          return article.category == 'Period & PCOS' ||
              article.category == 'Planning';
        case PregnancyStage.trying:
          return article.category == 'Planning' ||
              article.category == 'Period & PCOS' ||
              article.category == 'Partner';
        case PregnancyStage.pregnancy:
          return article.category == 'Pregnancy' ||
              article.category == 'Partner';
        case PregnancyStage.postpartum:
          return article.category == 'Postpartum' ||
              article.category == 'Partner';
      }
    }

    return article.category == state.selectedCategory;
  }).toList();
});
