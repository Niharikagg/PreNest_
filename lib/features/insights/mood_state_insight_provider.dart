import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../cycle/cycle_tracker_provider.dart';
import '../profile/profile_provider.dart';
import '../stage/stage.dart';
import '../stage/stage_provider.dart';

/// Available one-tap mood check-in descriptors.
const List<String> kAvailableMoodCheckIns = [
  'Calm',
  'Happy',
  'Tired',
  'Anxious',
  'Low Energy',
  'Irritable',
];

/// Data model representing a synthesized, non-diagnostic stage insight.
@immutable
class MoodStateInsight {
  final String activeMood;
  final PregnancyStage stage;
  final String stateSummary;
  final String professionalGuidance;
  final String sourceAttribution;
  final List<String> doctorQuestions;
  final String partnerSupportCue;
  final String partnerStateSummary;

  const MoodStateInsight({
    required this.activeMood,
    required this.stage,
    required this.stateSummary,
    required this.professionalGuidance,
    required this.sourceAttribution,
    required this.doctorQuestions,
    required this.partnerSupportCue,
    required this.partnerStateSummary,
  });
}

/// State notifier managing the currently selected one-tap mood check-in.
class ActiveMoodNotifier extends Notifier<String> {
  @override
  String build() => 'Tired';

  void setMood(String mood) {
    if (kAvailableMoodCheckIns.contains(mood)) {
      state = mood;
    }
  }
}

/// Provider for the active mood check-in selection.
final activeMoodProvider = NotifierProvider<ActiveMoodNotifier, String>(
  ActiveMoodNotifier.new,
);

/// Derived provider that synthesizes stage, mood, cycle symptoms, and partner context
/// into a medically sourced, non-diagnostic professional insight.
final moodStateInsightProvider = Provider<MoodStateInsight>((ref) {
  final stage = ref.watch(stageProvider);
  final mood = ref.watch(activeMoodProvider);
  final cycleState = ref.watch(cycleTrackerProvider);
  final couple = ref.watch(coupleProvider);
  final primaryName = couple.primaryPartner.name;

  final symptoms = cycleState.selectedSymptoms;
  final symptomText = symptoms.isNotEmpty ? symptoms.join(', ') : 'mild shifts';

  switch (stage) {
    case PregnancyStage.trying:
      // Period / PCOS mode
      return _buildPeriodPcosInsight(mood, symptomText, primaryName);

    case PregnancyStage.plan:
      // Planning for pregnancy mode
      return _buildPlanningInsight(mood, primaryName);

    case PregnancyStage.pregnancy:
      // Pregnant mode
      return _buildPregnancyInsight(mood, primaryName);

    case PregnancyStage.postpartum:
      // Postpartum mode
      return _buildPostpartumInsight(mood, primaryName);
  }
});

MoodStateInsight _buildPeriodPcosInsight(
  String mood,
  String symptomText,
  String herName,
) {
  String stateSummary;
  String guidance;
  List<String> questions;
  String partnerCue;

  switch (mood) {
    case 'Tired':
    case 'Low Energy':
      stateSummary =
          'Low energy and fatigue noted in Period/PCOS mode ($symptomText)';
      guidance =
          'During the luteal or pre-menstrual phase, physiological progesterone elevation and metabolic adaptations '
          'can lower available energy reserves. The Indian Council of Medical Research (ICMR) notes that women with irregular '
          'or PCOS-variant cycles often experience higher oxidative stress and insulin sensitivity shifts during this window.';
      questions = [
        'Could checking my serum ferritin or fasting insulin baseline explain persistent fatigue?',
        'Are there specific dietary micronutrients (like inositol or magnesium) suitable for my cycle profile?',
      ];
      partnerCue = 'She may be experiencing luteal energy dips. Offering to handle dinner or encouraging a quiet early bedtime creates deep physical relief.';
      break;

    case 'Anxious':
    case 'Irritable':
      stateSummary =
          'Heightened tension and mood sensitivity noted ($symptomText)';
      guidance =
          'Premenstrual neuro-endocrine sensitivity can temporarily alter serotonin and GABA receptor signaling. '
          'WHO reproductive guidelines highlight that regular low-impact ambulation (e.g., 20-minute gentle walks) '
          'and minimizing caffeine intake meaningfully ease premenstrual irritability without pharmaceutical intervention.';
      questions = [
        'Would tracking my symptoms across two full cycles help clarify if this is cyclical PMS/PMDD?',
        'Do you recommend any relaxation protocols or vitamin B6 supplementation for cyclical tension?',
      ];
      partnerCue = 'Emotional sensitivity is physically driven by hormonal shifts right now. A calm, listening presence without trying to "fix" things brings immense reassurance.';
      break;

    case 'Happy':
    case 'Calm':
    default:
      stateSummary = 'Balanced equilibrium & steady rhythm noted in cycle mode';
      guidance =
          'Estrogen dominance during the follicular phase generally correlates with higher mental alertness, '
          'steady blood sugar regulation, and enhanced emotional resilience. Maintaining balanced hydration '
          'and wholesome anti-inflammatory meals supports sustained ovulatory regularity.';
      questions = [
        'Is my current cycle length variation within a healthy physiological window for me?',
        'What preventive screening routine do you recommend at my next annual gynecological visit?',
      ];
      partnerCue = 'She is feeling calm and steady today. A wonderful time for an uplifting shared activity or planning upcoming goals together.';
      break;
  }

  return MoodStateInsight(
    activeMood: mood,
    stage: PregnancyStage.trying,
    stateSummary: stateSummary,
    professionalGuidance: guidance,
    sourceAttribution:
        'WHO Reproductive Health Advisory & ICMR PCOS Guidelines',
    doctorQuestions: questions,
    partnerSupportCue: partnerCue,
    partnerStateSummary:
        'Hormonal & cycle rhythm observation: $herName logged a $mood check-in.',
  );
}

MoodStateInsight _buildPlanningInsight(String mood, String herName) {
  String stateSummary;
  String guidance;
  List<String> questions;
  String partnerCue;

  switch (mood) {
    case 'Anxious':
      stateSummary =
          'Conception timeline anxiety noted during preconception planning';
      guidance =
          'Conception timing naturally spans several cycles for healthy couples (ACOG notes that up to 85% of couples '
          'conceive within 12 months of timed intercourse). Cortisol elevation from chronic stress can intermittently '
          'suppress hypothalamic GnRH release, delaying ovulation. Prioritizing shared calm over rigid calendar pressure is clinically proven.';
      questions = [
        'Are our current lifestyle and preconception supplement dosages optimal for both partners?',
        'At what point would formal fertility panel screening (AMH, semen analysis) be advisable for our timeline?',
      ];
      partnerCue = 'Planning journeys can feel quietly heavy. Remind her that conception is a shared journey, not an individual deadline, and enjoy an intentional date night.';
      break;

    case 'Tired':
    case 'Low Energy':
      stateSummary =
          'Physical exhaustion noted during preconception preparation';
      guidance =
          'Optimizing preconception reserves requires consistent restorative sleep (7–8 hours) and addressing subclinical '
          'anemia. WHO preconception standards emphasize that adequate maternal iron and active folate stores should be '
          'accumulated at least 2–3 months prior to active conception to support early organogenesis.';
      questions = [
        'Are my baseline complete blood count and thyroid (TSH) levels in the ideal pre-pregnancy bracket?',
        'Should we review the specific methylfolate vs folic acid formulation I am taking?',
      ];
      partnerCue = 'Support her physical restoration today by taking the lead on household prep and ensuring shared hydration goals.';
      break;

    case 'Calm':
    case 'Happy':
    default:
      stateSummary = 'Optimal readiness & steady lifestyle habits noted';
      guidance =
          'A calm physiological baseline optimizes the hypothalamic-pituitary-ovarian axis. Continuing daily preconception '
          'folic acid (400 mcg), balanced protein intake, and stress reduction creates the ideal uterine receptivity environment.';
      questions = [
        'Are there any specific preconception immunizations (e.g., Rubella IgG, Hepatitis B) I should confirm before conceiving?',
      ];
      partnerCue = 'She feels energized and grounded. Keep celebrating your shared health habits and mutual lifestyle consistency!';
      break;
  }

  return MoodStateInsight(
    activeMood: mood,
    stage: PregnancyStage.plan,
    stateSummary: stateSummary,
    professionalGuidance: guidance,
    sourceAttribution: 'ACOG Prepregnancy Care & WHO Preconception Standards',
    doctorQuestions: questions,
    partnerSupportCue: partnerCue,
    partnerStateSummary:
        'Preconception check-in: $herName reported a $mood state with steady wellness baselines.',
  );
}

MoodStateInsight _buildPregnancyInsight(String mood, String herName) {
  String stateSummary;
  String guidance;
  List<String> questions;
  String partnerCue;

  switch (mood) {
    case 'Tired':
    case 'Low Energy':
      stateSummary = 'Maternal fatigue noted during pregnancy progression';
      guidance =
          'Maternal cardiovascular volume expands by 40–50% during pregnancy, requiring substantial cardiac output '
          'and increased metabolic expenditure. MoHFW and ACOG guidelines recommend frequent short rest intervals, '
          'left-lateral resting to optimize placental perfusion, and monitoring hemoglobin levels to prevent gestational anemia.';
      questions = [
        'Is my current hemoglobin trend on track, and are my iron-folic acid (IFA) supplements absorbing well?',
        'How many rest intervals do you recommend daily for my current gestational week?',
      ];
      partnerCue = 'Baby is growing rapidly and her body is working overtime. Offer a relaxing foot rub or take over all lifting and chores tonight.';
      break;

    case 'Anxious':
      stateSummary = 'Gestational worry noted — trimester check-in';
      guidance =
          'Antenatal anxiety is common and responsive to reassurance and routine clinical checks. MoHFW guidelines '
          'advise discussing physical milestones openly during routine ANC visits. Daily kick counting in the third trimester '
          'or regular Doppler listens provide concrete evidence of fetal well-being, easing subjective worry.';
      questions = [
        'Could you review our recent scan and vitals milestones together so we understand what to expect next?',
        'What are the normal variations in fetal movement frequency for this gestational age?',
      ];
      partnerCue = 'Sit down together and listen calmly. Going over the upcoming ANC checklist or packing hospital items together can bring reassuring structure.';
      break;

    case 'Calm':
    case 'Happy':
    default:
      stateSummary = 'Second/third trimester steady adaptation & maternal calm';
      guidance =
          'Maternal calm enhances parasympathetic vagal tone, fostering a stable intrauterine physiological environment. '
          'Maintaining adequate hydration (2.5–3 liters), balanced calcium and IFA spacing, and gentle daily walking '
          'preserves optimal blood pressure and blood flow.';
      questions = [
        'When is my next scheduled glucose screening (OGTT) or growth ultrasound scan?',
        'Are my blood pressure readings consistently within safe clinical limits?',
      ];
      partnerCue = 'She is feeling calm and well today! Baby can hear voices now—talk or sing gently to her bump to build bonding.';
      break;
  }

  return MoodStateInsight(
    activeMood: mood,
    stage: PregnancyStage.pregnancy,
    stateSummary: stateSummary,
    professionalGuidance: guidance,
    sourceAttribution:
        'MoHFW Antenatal Care Guidelines & ACOG Practice Bulletin',
    doctorQuestions: questions,
    partnerSupportCue: partnerCue,
    partnerStateSummary:
        'Trimester status: $herName logged a $mood state with stable vitals indicators.',
  );
}

MoodStateInsight _buildPostpartumInsight(String mood, String herName) {
  String stateSummary;
  String guidance;
  List<String> questions;
  String partnerCue;

  switch (mood) {
    case 'Tired':
    case 'Low Energy':
      stateSummary = 'Postnatal exhaustion & recovery fatigue noted';
      guidance =
          'Postpartum recovery coincides with dramatic drop in progesterone and estrogen, accompanied by sleep fragmentation '
          'from round-the-clock newborn nursing. WHO and MoHFW postnatal care protocols recommend "horizontal resting" '
          'whenever the infant sleeps, avoiding prolonged standing, and maintaining continuous partner-assisted night shifts.';
      questions = [
        'Is my physical healing (perineal or surgical incision) progressing as expected for my postpartum week?',
        'Would checking my postpartum hemoglobin level help address persistent physical exhaustion?',
      ];
      partnerCue = 'Step in immediately to take the next infant soothing and burping shift so she can get at least 2–3 hours of uninterrupted, restorative sleep.';
      break;

    case 'Anxious':
    case 'Irritable':
      stateSummary =
          'Fourth trimester emotional strain & adjustment sensitivity';
      guidance =
          'The first 2–4 weeks postpartum involve intense neurochemical recalibration ("baby blues" vs postpartum adjustment). '
          'Tele-MANAS (14416) and WHO postnatal guidance emphasize that supportive partner involvement, protected rest, '
          'and regular warm meals are the primary buffers against postpartum distress. Persistent anxiety beyond 2 weeks warrants EPDS screening with a doctor.';
      questions = [
        'Could we review my EPDS mood screening score to evaluate if I need additional emotional recovery support?',
        'Are there local maternal support groups or counseling resources available through the clinic?',
      ];
      partnerCue = 'Her hormone levels are resetting after birth. Protect her environment from overwhelming visitors, bring her warm tea, and listen with tenderness.';
      break;

    case 'Calm':
    case 'Happy':
    default:
      stateSummary = 'Positive postnatal bonding & steady recovery rhythm';
      guidance =
          'Skin-to-skin contact and successful feeding establish robust oxytocin and prolactin release, promoting uterine '
          'involution and emotional bonding. Continuing nourishing Indian postpartum meals (daliya, moringa, jeera water) '
          'maintains high-quality milk synthesis and maternal tissue repair.';
      questions = [
        'What milestone checks are scheduled for my 6-week comprehensive maternal recovery appointment?',
        'Is baby’s weight gain tracking well along the pediatric growth curve?',
      ];
      partnerCue = 'She is feeling steady and bonded today. Celebrate how far both of you have come in caring for your little one!';
      break;
  }

  return MoodStateInsight(
    activeMood: mood,
    stage: PregnancyStage.postpartum,
    stateSummary: stateSummary,
    professionalGuidance: guidance,
    sourceAttribution: 'WHO Postnatal Care Guidelines & MoHFW India Advisory',
    doctorQuestions: questions,
    partnerSupportCue: partnerCue,
    partnerStateSummary:
        'Fourth trimester observation: $herName logged a $mood state with ongoing recovery routines.',
  );
}
