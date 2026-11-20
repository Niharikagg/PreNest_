import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../stage/stage.dart';
import '../stage/stage_provider.dart';

/// Presentation and clinical data model for a stage-specific symptom or discomfort.
@immutable
class StageSymptomItem {
  final String id;
  final String title;
  final PregnancyStage stage;
  final bool isRedFlag;
  final IconData icon;
  final String description;
  final String comfortTips;
  final String whenToConsultDoctor;
  final String clinicalRationale;
  final String sourceAttribution;
  final List<String> doctorQuestions;

  const StageSymptomItem({
    required this.id,
    required this.title,
    required this.stage,
    required this.isRedFlag,
    required this.icon,
    required this.description,
    required this.comfortTips,
    required this.whenToConsultDoctor,
    required this.clinicalRationale,
    required this.sourceAttribution,
    this.doctorQuestions = const [],
  });
}

/// Catalog of evidence-based, non-diagnostic symptoms across all 4 modes.
const List<StageSymptomItem> kSymptomCatalog = [
  // ==========================================
  // MODE 1: PERIOD & PCOS (PregnancyStage.trying)
  // ==========================================
  // Common Discomforts
  StageSymptomItem(
    id: 'pcos_cramps',
    title: 'Mild Menstrual Cramps',
    stage: PregnancyStage.trying,
    isRedFlag: false,
    icon: Icons.water_drop_outlined,
    description: 'Dull, aching lower abdominal pressure during cycle days 1–3.',
    comfortTips: 'Apply a warm heating pad to the lower abdomen for 15–20 minutes. Sip warm ginger or chamomile tea. Gentle pelvic rocking or child’s pose relieves pelvic floor tension.',
    whenToConsultDoctor: 'Mention at routine visit if cramps regularly prevent normal daily activities or don’t respond to simple warmth/rest.',
    clinicalRationale: 'Prostaglandin release triggers uterine muscle contractions to shed the endometrium. Mild cramping is a normal physiological process.',
    sourceAttribution:
        'ACOG Dysmenorrhea Clinical Guide & WHO Reproductive Health',
    doctorQuestions: [
      'Are my menstrual cramp patterns typical for my cycle length?',
      'Would anti-inflammatory nutrition or magnesium glycinate be suitable for me?',
    ],
  ),
  StageSymptomItem(
    id: 'pcos_bloating',
    title: 'Abdominal Bloating & Water Retention',
    stage: PregnancyStage.trying,
    isRedFlag: false,
    icon: Icons.bubble_chart_outlined,
    description: 'Feeling of abdominal fullness or temporary fluid retention in the luteal phase.',
    comfortTips: 'Maintain steady hydration (2–2.5 L) to signal kidneys to excrete excess sodium. Enjoy potassium-rich foods (bananas, coconut water) and reduce refined carbohydrates and salty snacks.',
    whenToConsultDoctor: 'Consult if bloating is accompanied by severe abdominal pain, sudden extreme swelling, or rapid weight gain.',
    clinicalRationale: 'Elevated progesterone slows gastrointestinal transit time and alters aldosterone fluid balance in the premenstrual window.',
    sourceAttribution: 'ICMR Nutrition Guidelines & ACOG Clinical Opinion',
    doctorQuestions: [
      'Could my bloating be connected to insulin sensitivity shifts in my cycle?',
    ],
  ),
  StageSymptomItem(
    id: 'pcos_fatigue',
    title: 'Mild Premenstrual Fatigue',
    stage: PregnancyStage.trying,
    isRedFlag: false,
    icon: Icons.bedtime_outlined,
    description: 'Noticeable drop in daytime energy and stamina 3–7 days before expected cycle.',
    comfortTips: 'Honor your body by scheduling an earlier bedtime. Prioritize iron-rich meals (spinach, lentils, dates) combined with vitamin C (amla, lemon). Take short 15-minute sunshine walks.',
    whenToConsultDoctor: 'Mention if fatigue is constant throughout the entire month regardless of sleep or cycle phase.',
    clinicalRationale: 'Progesterone has natural mild neuro-sedative properties, and iron stores fluctuate during menstrual shedding.',
    sourceAttribution: 'WHO Anemia Prevention Protocol & ICMR',
    doctorQuestions: [
      'Should we check my serum ferritin, vitamin D3, and TSH levels at my next checkup?',
    ],
  ),
  StageSymptomItem(
    id: 'pcos_skin',
    title: 'Hormonal Acne / Skin Flare-ups',
    stage: PregnancyStage.trying,
    isRedFlag: false,
    icon: Icons.face_retouching_natural_outlined,
    description:
        'Jawline or chin breakouts occurring cyclically prior to period onset.',
    comfortTips: 'Use gentle, non-comedogenic cleansers and avoid picking lesions. Hydrate with spearmint tea or water, and minimize dairy or high-glycemic sugar spikes.',
    whenToConsultDoctor: 'Discuss with gynecologist/dermatologist if acne is cystic, persistent, or accompanied by sudden facial hair thinning/growth.',
    clinicalRationale: 'Relative androgen activity compared to dropping estrogen stimulates sebaceous gland sebum production.',
    sourceAttribution: 'ICMR PCOS Consensus Guidelines',
    doctorQuestions: [
      'Could an inositol-based supplement or metabolic nutrition plan help balance hormonal skin flares?',
    ],
  ),

  // Period Red Flags
  StageSymptomItem(
    id: 'pcos_severe_pain',
    title: 'Severe Debilitating Pelvic Pain',
    stage: PregnancyStage.trying,
    isRedFlag: true,
    icon: Icons.warning_amber_rounded,
    description: 'Sudden, sharp, agonizing or rigid pelvic pain that is unmanageable with rest.',
    comfortTips: 'Do not wait or rely on home remedies. Lie down and arrange prompt clinical evaluation.',
    whenToConsultDoctor: 'Immediate doctor review required. Emergency triage needed if pain causes vomiting or inability to stand.',
    clinicalRationale: 'Risk of acute ovarian torsion, ruptured hemorrhagic ovarian cyst, acute pelvic inflammatory disease (PID), or ectopic pregnancy.',
    sourceAttribution:
        'MoHFW 108 Emergency Protocol & ACOG Acute Pelvic Pain Guidelines',
    doctorQuestions: [
      'Does my severe acute pain indicate a ruptured cyst or require an immediate ultrasound scan?',
    ],
  ),
  StageSymptomItem(
    id: 'pcos_heavy_bleeding',
    title: 'Unusually Heavy Bleeding (Soaking Pad < 1h)',
    stage: PregnancyStage.trying,
    isRedFlag: true,
    icon: Icons.bloodtype_outlined,
    description: 'Soaking through a sanitary pad completely in 1 hour or less for 2+ consecutive hours, or passing golf-ball sized clots.',
    comfortTips: 'Rest horizontally, note pad counts, and seek prompt clinical care without delay.',
    whenToConsultDoctor: 'Emergency medical review required to prevent acute hypovolemia and severe blood loss.',
    clinicalRationale: 'Risk of severe uterine bleeding, endometrial hyperplasia, submucosal fibroid hemorrhage, or coagulopathy.',
    sourceAttribution:
        'MoHFW Maternal Health Division & ACOG Abnormal Uterine Bleeding',
    doctorQuestions: [
      'Do I need immediate medication or IV fluids to control this acute flow rate?',
    ],
  ),
  StageSymptomItem(
    id: 'pcos_fever_pelvic',
    title: 'High Fever with Pelvic Tenderness',
    stage: PregnancyStage.trying,
    isRedFlag: true,
    icon: Icons.thermostat_outlined,
    description: 'Temperature exceeding 100.4°F (38°C) accompanied by deep pelvic throbbing or abnormal foul discharge.',
    comfortTips: 'Avoid warm baths. Seek prompt clinical examination and prescribed antibiotic review.',
    whenToConsultDoctor: 'Immediate doctor visit recommended to rule out upper reproductive tract infection.',
    clinicalRationale: 'Risk of acute endometritis, tubo-ovarian abscess, or severe pelvic infection.',
    sourceAttribution: 'WHO Reproductive Tract Infections Advisory',
    doctorQuestions: [
      'Are pelvic culture swabs and blood tests needed to target appropriate antimicrobial therapy?',
    ],
  ),

  // ==========================================
  // MODE 2: PLANNING FOR PREGNANCY (PregnancyStage.plan)
  // ==========================================
  // Common Discomforts
  StageSymptomItem(
    id: 'plan_ovulation_pain',
    title: 'Mild Mid-Cycle Ovulation Twinge (Mittelschmerz)',
    stage: PregnancyStage.plan,
    isRedFlag: false,
    icon: Icons.spa_outlined,
    description: 'Brief, mild one-sided lower abdominal twinge lasting a few hours to 1 day mid-cycle.',
    comfortTips: 'A warm bath or resting with a warm compress eases localized follicular tension. Staying hydrated and tracking this alongside cervical mucus confirms ovulatory timing.',
    whenToConsultDoctor: 'Mention at routine visit if the pain lasts several days or intensifies progressively.',
    clinicalRationale: 'Normal stretching of the ovarian capsule and minor peritoneal irritation during dominant follicle rupture.',
    sourceAttribution: 'ACOG Clinical Guidance & WHO Preconception Protocol',
    doctorQuestions: [
      'Does my mid-cycle twinge align accurately with my ovulation test strip results?',
    ],
  ),
  StageSymptomItem(
    id: 'plan_supp_nausea',
    title: 'Mild Preconception Supplement Nausea',
    stage: PregnancyStage.plan,
    isRedFlag: false,
    icon: Icons.medication_liquid_outlined,
    description: 'Slight stomach queasiness shortly after taking preconception multivitamins or iron.',
    comfortTips: 'Never take iron or multivitamin tablets on an empty stomach. Take supplements alongside lunch or a light snack. Avoid taking iron simultaneously with dairy or calcium.',
    whenToConsultDoctor: 'Ask doctor if nausea leads to vomiting or inability to keep daily folate/multivitamins down.',
    clinicalRationale: 'Elemental iron compounds can cause mild transient gastric mucosal irritation.',
    sourceAttribution: 'ICMR-National Institute of Nutrition (NIN)',
    doctorQuestions: [
      'Could we switch to a gentler chelated iron formulation or split my multivitamin dose?',
    ],
  ),
  StageSymptomItem(
    id: 'plan_sleep_disruption',
    title: 'Mild Preconception Restlessness',
    stage: PregnancyStage.plan,
    isRedFlag: false,
    icon: Icons.nights_stay_outlined,
    description: 'Occasional difficulty falling asleep due to mind racing about conception timelines.',
    comfortTips: 'Institute a screen-free wind-down routine 45 minutes before sleep. Practice 4-7-8 diaphragmatic breathing with your partner or listen to calming audio.',
    whenToConsultDoctor: 'Mention if insomnia is severe or accompanied by daytime anxiety affecting function.',
    clinicalRationale: 'Anticipatory stress can elevate evening cortisol, interfering with natural melatonin production.',
    sourceAttribution: 'WHO Mental Health Advisory & ACOG',
    doctorQuestions: [
      'Are there safe relaxation techniques or supplements you recommend for preconception sleep?',
    ],
  ),

  // Planning Red Flags
  StageSymptomItem(
    id: 'plan_acute_unilateral_pain',
    title: 'Acute Severe One-Sided Abdominal Pain',
    stage: PregnancyStage.plan,
    isRedFlag: true,
    icon: Icons.emergency_outlined,
    description: 'Sudden, sharp, agonizing pain concentrated in one lower quadrant, potentially radiating to shoulder.',
    comfortTips: 'Do not take painkillers that mask symptoms. Seek immediate emergency evaluation.',
    whenToConsultDoctor:
        'Emergency hospital visit or 108 dispatch required immediately.',
    clinicalRationale: 'Critical risk of early ruptured ectopic pregnancy (if conception occurred unnoticed) or adnexal torsion.',
    sourceAttribution: 'MoHFW Emergency Obstetrics Protocol & ACOG Ectopic Pregnancy Guidelines',
    doctorQuestions: [
      'Could this acute one-sided pain indicate an ectopic pregnancy or ovarian cyst rupture?',
    ],
  ),
  StageSymptomItem(
    id: 'plan_syncope',
    title: 'Sudden Fainting, Dizziness or Collapse',
    stage: PregnancyStage.plan,
    isRedFlag: true,
    icon: Icons.person_off_outlined,
    description: 'Momentary loss of consciousness, extreme postural lightheadedness, or sudden graying vision.',
    comfortTips: 'Lie flat with feet elevated immediately. Seek urgent medical evaluation.',
    whenToConsultDoctor: 'Emergency medical review required.',
    clinicalRationale: 'Risk of acute internal hemorrhage, severe vasovagal collapse, or cardiac arrhythmia.',
    sourceAttribution: 'MoHFW Emergency Triage Advisory',
    doctorQuestions: [
      'What urgent tests (CBC, ECG, pelvic scan) are needed to investigate this collapse?',
    ],
  ),

  // ==========================================
  // MODE 3: PREGNANT (PregnancyStage.pregnancy)
  // ==========================================
  // Common Discomforts
  StageSymptomItem(
    id: 'preg_morning_sickness',
    title: 'Mild Morning Sickness / Mild Nausea',
    stage: PregnancyStage.pregnancy,
    isRedFlag: false,
    icon: Icons.sick_outlined,
    description: 'Mild wave of nausea in morning or evening, without severe inability to keep fluids down.',
    comfortTips: 'Keep dry crackers or roasted almonds by your bedside and eat a few bites before rising. Eat small, frequent meals every 2 hours. Sip ginger-infused warm water or lemon water.',
    whenToConsultDoctor: 'Consult promptly if vomiting occurs multiple times daily, you cannot keep fluids down for 24h, or you lose weight (Hyperemesis Gravidarum).',
    clinicalRationale: 'Rapid surge in human chorionic gonadotropin (hCG) and estrogen relaxes smooth muscle tissue throughout the GI tract.',
    sourceAttribution:
        'MoHFW Antenatal Guidelines & ACOG Nausea Practice Bulletin',
    doctorQuestions: [
      'Are vitamin B6 (pyridoxine) or prescription anti-emetics suitable if nausea worsens?',
    ],
  ),
  StageSymptomItem(
    id: 'preg_round_ligament',
    title: 'Round Ligament Stretching Pain',
    stage: PregnancyStage.pregnancy,
    isRedFlag: false,
    icon: Icons.airline_seat_legroom_reduced_outlined,
    description: 'Brief, sharp or jabbing twinge in the lower groin when coughing, sneezing, or standing up quickly.',
    comfortTips: 'Avoid sudden jerky movements. Bend your hips slightly when sneezing or coughing. A warm bath and a gentle maternity support band ease gravitational tension.',
    whenToConsultDoctor: 'Consult if pain is persistent, continuous, accompanied by fever, bleeding, or difficulty walking.',
    clinicalRationale: 'The round ligaments supporting the uterus stretch and thin under rapid gestational growth and relaxin hormone.',
    sourceAttribution: 'ACOG Pregnancy FAQs & MoHFW Maternal Health',
    doctorQuestions: [
      'Would prenatal physiotherapy or targeted stretching help my pelvic stability?',
    ],
  ),
  StageSymptomItem(
    id: 'preg_backache',
    title: 'Mild Lower Back & Sacral Strain',
    stage: PregnancyStage.pregnancy,
    isRedFlag: false,
    icon: Icons.accessibility_new_outlined,
    description: 'Dull lower back ache toward the end of the day from postural center-of-gravity shifts.',
    comfortTips: 'Sleep on your left side with a pillow between your knees and under your belly. Wear low-heeled supportive footwear. Avoid prolonged standing without shifting weight.',
    whenToConsultDoctor: 'Consult if back pain comes in rhythmic tightening waves (preterm labor sign) or radiates down the leg with numbness.',
    clinicalRationale: 'Relaxin hormone loosens pelvic ligaments while expanding uterine weight shifts the lumbar spine curvature forward.',
    sourceAttribution: 'WHO Antenatal Care for a Positive Pregnancy Experience',
    doctorQuestions: [
      'What gentle prenatal pelvic tilts or safe exercises do you recommend for my back?',
    ],
  ),
  StageSymptomItem(
    id: 'preg_heartburn',
    title: 'Occasional Heartburn & Reflux',
    stage: PregnancyStage.pregnancy,
    isRedFlag: false,
    icon: Icons.local_fire_department_outlined,
    description: 'Warm burning sensation in chest or throat after meals, especially when reclining.',
    comfortTips: 'Eat smaller portions slowly. Remain upright for at least 60–90 minutes after eating. Elevate the head of your bed by 6 inches. Avoid spicy, excessively oily, or deeply fried foods.',
    whenToConsultDoctor: 'Consult if heartburn is severe, constant, or accompanied by severe right upper quadrant/epigastric pain.',
    clinicalRationale: 'Progesterone relaxes the lower esophageal sphincter, and the growing uterus exerts upward gastric pressure.',
    sourceAttribution: 'ACOG Patient Education & ICMR',
    doctorQuestions: [
      'Which over-the-counter antacids (calcium-based) are safe for my trimester?',
    ],
  ),
  StageSymptomItem(
    id: 'preg_braxton_hicks',
    title: 'Braxton Hicks Mild Practice Tightening',
    stage: PregnancyStage.pregnancy,
    isRedFlag: false,
    icon: Icons.timer_outlined,
    description: 'Painless, irregular tightening of the uterine muscle that subsides with movement or water.',
    comfortTips: 'Drink 2 tall glasses of room-temperature water (dehydration triggers uterine irritability). Change your position—lie on your left side or take a gentle stroll.',
    whenToConsultDoctor: 'Seek urgent hospital evaluation if contractions become regular, painful, occur every 10 minutes or less (preterm labor), or are accompanied by bleeding/fluid leak.',
    clinicalRationale: 'Physiological uterine muscle toning and practice contractions that do not dilate the cervix.',
    sourceAttribution: 'ACOG Labor & Delivery Clinical Guidelines',
    doctorQuestions: [
      'How can I best distinguish between Braxton Hicks and true early preterm labor signs?',
    ],
  ),

  // Pregnancy Red Flags
  StageSymptomItem(
    id: 'preg_red_headache',
    title: 'Severe Headache with Blurred Vision',
    stage: PregnancyStage.pregnancy,
    isRedFlag: true,
    icon: Icons.visibility_off_rounded,
    description: 'Pounding, unremitting headache with visual disturbances (spots, flashing lights, blurred vision) or right upper quadrant pain.',
    comfortTips: 'Do not rest and wait. Seek emergency obstetric blood pressure evaluation immediately.',
    whenToConsultDoctor: 'Emergency evaluation required immediately. Risk of impending eclampsia.',
    clinicalRationale: 'Cardinal sign of severe preeclampsia / impending eclampsia requiring urgent antihypertensive control and magnesium sulfate protocol.',
    sourceAttribution:
        'MoHFW Preeclampsia Guidelines & WHO Maternal Safety Advisory',
    doctorQuestions: [
      'What is my immediate blood pressure and urine protein reading?',
    ],
  ),
  StageSymptomItem(
    id: 'preg_red_fetal_movement',
    title: 'Reduced or Absent Baby Movements',
    stage: PregnancyStage.pregnancy,
    isRedFlag: true,
    icon: Icons.child_care_rounded,
    description: 'Noticeable drop in baby kicks, absence of movement for 2+ hours, or failing to reach 10 kicks in 2 hours in 3rd trimester.',
    comfortTips: 'Drink a cold glass of water, lie on your left side in a quiet room, and focus exclusively on movement. If no response, go to hospital immediately.',
    whenToConsultDoctor: 'Immediate hospital triage required. Same-day NST/CTG fetal heart rate scan necessary.',
    clinicalRationale: 'Decreased fetal movement is a sensitive early indicator of placental insufficiency or fetal hypoxia.',
    sourceAttribution: 'MoHFW Stillbirth Prevention Strategy & ACOG Antepartum Fetal Surveillance',
    doctorQuestions: [
      'Can we perform an immediate cardiotocography (CTG) or biophysical profile scan?',
    ],
  ),
  StageSymptomItem(
    id: 'preg_red_bleeding',
    title: 'Vaginal Bleeding or Sudden Fluid Leak',
    stage: PregnancyStage.pregnancy,
    isRedFlag: true,
    icon: Icons.bloodtype_rounded,
    description: 'Any bright red vaginal bleeding (with or without pain) or continuous clear/greenish amniotic fluid leakage.',
    comfortTips: 'Put on a clean maternity pad, note the color and fluid rate, and head directly to maternity emergency.',
    whenToConsultDoctor: 'Immediate hospital emergency admission or Call 108.',
    clinicalRationale: 'Risk of placental abruption, placenta previa, or premature rupture of membranes (PROM) with infection risk.',
    sourceAttribution: 'MoHFW Emergency Obstetric Care & WHO Guidelines',
    doctorQuestions: [
      'Is my placenta intact, and has membrane rupture occurred?',
    ],
  ),
  StageSymptomItem(
    id: 'preg_red_severe_pain',
    title: 'Severe Constant Abdominal Pain / Rigid Belly',
    stage: PregnancyStage.pregnancy,
    isRedFlag: true,
    icon: Icons.healing_rounded,
    description: 'Intense, continuous uterine pain where the belly feels rock hard or tender to light touch.',
    comfortTips: 'Do not apply pressure. Call 108 or arrange immediate ambulance transport to delivery facility.',
    whenToConsultDoctor: 'Life-threatening obstetric emergency requiring immediate hospital resuscitation.',
    clinicalRationale: 'High risk of placental abruption (premature separation) or uterine rupture.',
    sourceAttribution:
        'MoHFW 108 Emergency Ambulance Protocol & ACOG Clinical Guidance',
    doctorQuestions: [
      'Immediate ultrasound and continuous maternal-fetal monitoring required.',
    ],
  ),

  // ==========================================
  // MODE 4: POSTPARTUM (PregnancyStage.postpartum)
  // ==========================================
  // Common Discomforts
  StageSymptomItem(
    id: 'post_afterpains',
    title: 'Mild Afterpains While Nursing',
    stage: PregnancyStage.postpartum,
    isRedFlag: false,
    icon: Icons.favorite_border_rounded,
    description: 'Menstrual-like uterine cramping felt most noticeably during or immediately after baby latches.',
    comfortTips: 'Empty your bladder before nursing. Apply a warm heating pad to your lower abdomen while feeding. Practice slow, deep belly breathing.',
    whenToConsultDoctor: 'Mention if cramps become severely sharp, constant, or accompanied by foul-smelling lochia or fever.',
    clinicalRationale: 'Nursing stimulates natural oxytocin release, contracting the uterus back to its pre-pregnancy size (involution).',
    sourceAttribution: 'WHO Postnatal Care & ACOG Postpartum Toolkit',
    doctorQuestions: [
      'Are mild paracetamol doses safe while establishing breastfeeding if afterpains interfere with rest?',
    ],
  ),
  StageSymptomItem(
    id: 'post_perineal_soreness',
    title: 'Perineal Soreness / Healing Incision',
    stage: PregnancyStage.postpartum,
    isRedFlag: false,
    icon: Icons.spa_outlined,
    description: 'Mild tenderness around the vaginal tear/episiotomy or C-section incision site during the first 1–2 weeks.',
    comfortTips: 'Rinse with warm water using a peri-bottle after urination; gently pat dry with clean gauze. Short warm sitz baths (10 min) or chilled witch hazel pads soothe soreness.',
    whenToConsultDoctor: 'Seek prompt doctor review if incision edges gape open, ooze pus/foul discharge, or show spreading fiery redness.',
    clinicalRationale: 'Soft tissue and muscular healing requires 2–6 weeks of gentle hygiene and avoiding excessive intra-abdominal strain.',
    sourceAttribution: 'MoHFW Postnatal Clinical Advisory & WHO Guidelines',
    doctorQuestions: [
      'Is my perineal/surgical healing proceeding normally at my 2-week check?',
    ],
  ),
  StageSymptomItem(
    id: 'post_engorgement',
    title: 'Mild Breast Fullness & Engorgement',
    stage: PregnancyStage.postpartum,
    isRedFlag: false,
    icon: Icons.water_drop_outlined,
    description: 'Breasts feeling warm, heavy, and firm around days 3–5 as transitional milk comes in.',
    comfortTips: 'Nurse on demand frequently (8–12 times per 24h). Hand-express a few drops before latch to soften the areola. Apply cold compresses or chilled cabbage leaves after feeding to soothe swelling.',
    whenToConsultDoctor: 'Consult doctor or lactation consultant if baby cannot latch, or if you develop fever, chills, or a hard red wedge.',
    clinicalRationale: 'Sudden surge in prolactin combined with increased blood and lymphatic circulation to the mammary glands.',
    sourceAttribution: 'UNICEF & WHO Infant and Young Child Feeding (IYCF)',
    doctorQuestions: [
      'Can a lactation counselor check my baby\'s latch depth to prevent recurrent engorgement?',
    ],
  ),

  // Postpartum Red Flags
  StageSymptomItem(
    id: 'post_red_hemorrhage',
    title: 'Heavy Secondary Postpartum Hemorrhage',
    stage: PregnancyStage.postpartum,
    isRedFlag: true,
    icon: Icons.bloodtype_rounded,
    description: 'Sudden gush or soaking more than 1 maternity pad per hour, or passing clots larger than a lemon.',
    comfortTips: 'Do not wait. Lie flat, call 108 immediately, and bring your hospital discharge summary.',
    whenToConsultDoctor: 'Emergency medical triage required immediately.',
    clinicalRationale: 'Risk of secondary postpartum hemorrhage (PPH) from retained placental fragments, uterine subinvolution, or infection.',
    sourceAttribution:
        'MoHFW 108 Protocol & WHO Postpartum Hemorrhage Guidelines',
    doctorQuestions: [
      'Immediate ultrasound needed to evaluate for retained placental tissue.',
    ],
  ),
  StageSymptomItem(
    id: 'post_red_mastitis',
    title: 'Painful Breast Redness with High Fever (Mastitis)',
    stage: PregnancyStage.postpartum,
    isRedFlag: true,
    icon: Icons.local_hospital_rounded,
    description: 'Hot, tender, fiery red wedge or streak on the breast accompanied by high fever (>101°F) and flu-like body aches.',
    comfortTips: 'Continue nursing or gently expressing from the affected side to prevent abscess. Seek immediate doctor review for prescription antibiotics.',
    whenToConsultDoctor: 'Doctor consultation required within 24 hours to prevent breast abscess formation.',
    clinicalRationale: 'Bacterial infection of the breast tissue (often Staph aureus) entering via cracked nipples or milk stasis.',
    sourceAttribution: 'ACOG Clinical Guidance on Mastitis & WHO',
    doctorQuestions: [
      'Which breastfeeding-compatible antibiotics and pain relievers do you prescribe?',
    ],
  ),
  StageSymptomItem(
    id: 'post_red_calf_pain',
    title: 'Unilateral Swollen, Painful Calf (DVT)',
    stage: PregnancyStage.postpartum,
    isRedFlag: true,
    icon: Icons.warning_rounded,
    description: 'Pain, throbbing, warmth, or noticeable swelling in only one leg or calf, worse when flexing toes upward.',
    comfortTips: 'Do not massage the calf. Keep leg still and seek immediate emergency ultrasound.',
    whenToConsultDoctor: 'Emergency hospital evaluation required immediately.',
    clinicalRationale: 'High risk of Deep Vein Thrombosis (DVT), which can dislodge and cause life-threatening Pulmonary Embolism (PE).',
    sourceAttribution:
        'MoHFW Venous Thromboembolism Protocol & ACOG Practice Bulletin',
    doctorQuestions: [
      'Urgent lower limb venous Doppler ultrasound required immediately.',
    ],
  ),
  StageSymptomItem(
    id: 'post_red_mental_health',
    title: 'Severe Panic, Hallucinations or Self-Harm Thoughts',
    stage: PregnancyStage.postpartum,
    isRedFlag: true,
    icon: Icons.psychology_rounded,
    description: 'Overwhelming despair, severe thoughts of self-harm or harming baby, detachment from reality, or intense insomnia.',
    comfortTips: 'Ensure a family member stays with mother and baby at all times. Call Tele-MANAS (14416) or doctor immediately.',
    whenToConsultDoctor:
        'Immediate psychiatric and medical evaluation required.',
    clinicalRationale: 'Postpartum depression or rare postpartum psychosis requiring urgent psychiatric support and safe intervention.',
    sourceAttribution:
        'Tele-MANAS (MoHFW Toll-Free 14416) & WHO Maternal Mental Health',
    doctorQuestions: [
      'Immediate crisis evaluation and coordinated partner/family safety plan needed.',
    ],
  ),
];

/// State model for the cross-mode symptom checker.
@immutable
class SymptomCheckerState {
  final PregnancyStage activeStage;
  final String? selectedSymptomId;
  final String searchQuery;

  const SymptomCheckerState({
    required this.activeStage,
    this.selectedSymptomId,
    this.searchQuery = '',
  });

  SymptomCheckerState copyWith({
    PregnancyStage? activeStage,
    String? selectedSymptomId,
    bool clearSelectedSymptom = false,
    String? searchQuery,
  }) {
    return SymptomCheckerState(
      activeStage: activeStage ?? this.activeStage,
      selectedSymptomId: clearSelectedSymptom
          ? null
          : (selectedSymptomId ?? this.selectedSymptomId),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  /// All symptoms available for the active stage.
  List<StageSymptomItem> get stageSymptoms {
    return kSymptomCatalog.where((s) => s.stage == activeStage).toList();
  }

  /// Common discomfort items for active stage.
  List<StageSymptomItem> get commonDiscomforts {
    return stageSymptoms.where((s) => !s.isRedFlag).toList();
  }

  /// Red-flag / prompt review symptoms for active stage.
  List<StageSymptomItem> get redFlags {
    return stageSymptoms.where((s) => s.isRedFlag).toList();
  }

  /// Currently selected symptom item (if any).
  StageSymptomItem? get selectedSymptom {
    if (selectedSymptomId == null) return null;
    return kSymptomCatalog.firstWhere(
      (s) => s.id == selectedSymptomId,
      orElse: () => stageSymptoms.first,
    );
  }
}

/// Riverpod Notifier managing the cross-mode symptom checker state.
class SymptomCheckerNotifier extends Notifier<SymptomCheckerState> {
  @override
  SymptomCheckerState build() {
    // Defaults to the globally active stage from stageProvider
    final currentStage = ref.watch(stageProvider);
    // Pre-select first common discomfort for smooth exploration
    final initialList = kSymptomCatalog
        .where((s) => s.stage == currentStage)
        .toList();
    final firstId = initialList.isNotEmpty ? initialList.first.id : null;

    return SymptomCheckerState(
      activeStage: currentStage,
      selectedSymptomId: firstId,
    );
  }

  void setStage(PregnancyStage stage) {
    final stageItems = kSymptomCatalog.where((s) => s.stage == stage).toList();
    final firstId = stageItems.isNotEmpty ? stageItems.first.id : null;
    state = state.copyWith(activeStage: stage, selectedSymptomId: firstId);
  }

  void selectSymptom(String symptomId) {
    state = state.copyWith(selectedSymptomId: symptomId);
  }

  void clearSelection() {
    state = state.copyWith(clearSelectedSymptom: true);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query.trim());
  }
}

/// Global provider delivering the Symptom Checker state and actions.
final symptomCheckerProvider =
    NotifierProvider<SymptomCheckerNotifier, SymptomCheckerState>(
      SymptomCheckerNotifier.new,
    );
