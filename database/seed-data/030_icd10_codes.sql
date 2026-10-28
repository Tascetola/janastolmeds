--liquibase formatted sql

--changeset adetola:seed-icd10-001 runOnChange:false
--comment: Seed JM_ICD10_CODES with 200 common outpatient diagnoses (WHO ICD-10), FR-CLN-03 and FR-PAT-05. Reference data for all environments.
-- Extend with new changesets; never edit this one after it has run.


-- Chapter I: Infectious and parasitic diseases
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('A01.0', 'Typhoid fever', 'I', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('A06.0', 'Acute amoebic dysentery', 'I', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('A09.9', 'Gastroenteritis and colitis of unspecified origin', 'I', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('A15.0', 'Tuberculosis of lung, confirmed by sputum microscopy with or without culture', 'I', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('A16.9', 'Respiratory tuberculosis unspecified, without bacteriological or histological confirmation', 'I', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('A49.9', 'Bacterial infection, unspecified', 'I', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('A53.9', 'Syphilis, unspecified', 'I', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('A54.9', 'Gonococcal infection, unspecified', 'I', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('A56.0', 'Chlamydial infection of lower genitourinary tract', 'I', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('A59.0', 'Urogenital trichomoniasis', 'I', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('A96.2', 'Lassa fever', 'I', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('B01.9', 'Varicella without complication', 'I', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('B02.9', 'Zoster without complication', 'I', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('B05.9', 'Measles without complication', 'I', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('B15.9', 'Hepatitis A without hepatic coma', 'I', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('B16.9', 'Acute hepatitis B without delta-agent and without hepatic coma', 'I', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('B18.1', 'Chronic viral hepatitis B without delta-agent', 'I', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('B18.2', 'Chronic viral hepatitis C', 'I', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('B24', 'Unspecified human immunodeficiency virus [HIV] disease', 'I', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('B34.9', 'Viral infection, unspecified', 'I', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('B35.4', 'Tinea corporis', 'I', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('B36.0', 'Pityriasis versicolor', 'I', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('B37.0', 'Candidal stomatitis', 'I', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('B37.3', 'Candidiasis of vulva and vagina', 'I', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('B50.0', 'Plasmodium falciparum malaria with cerebral complications', 'I', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('B50.9', 'Plasmodium falciparum malaria, unspecified', 'I', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('B54', 'Unspecified malaria', 'I', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('B76.9', 'Hookworm disease, unspecified', 'I', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('B77.9', 'Ascariasis, unspecified', 'I', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('B82.9', 'Intestinal parasitism, unspecified', 'I', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('B86', 'Scabies', 'I', 'N');

-- Chapter II: Neoplasms
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('C50.9', 'Malignant neoplasm of breast, unspecified', 'II', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('C61', 'Malignant neoplasm of prostate', 'II', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('D25.9', 'Leiomyoma of uterus, unspecified', 'II', 'Y');

-- Chapter III: Blood and immune disorders
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('D50.9', 'Iron deficiency anaemia, unspecified', 'III', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('D57.0', 'Sickle-cell anaemia with crisis', 'III', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('D57.1', 'Sickle-cell anaemia without crisis', 'III', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('D57.3', 'Sickle-cell trait', 'III', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('D64.9', 'Anaemia, unspecified', 'III', 'N');

-- Chapter IV: Endocrine, nutritional and metabolic
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('E03.9', 'Hypothyroidism, unspecified', 'IV', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('E04.9', 'Nontoxic goitre, unspecified', 'IV', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('E05.9', 'Thyrotoxicosis, unspecified', 'IV', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('E10.9', 'Type 1 diabetes mellitus without complications', 'IV', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('E11.2', 'Type 2 diabetes mellitus with renal complications', 'IV', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('E11.4', 'Type 2 diabetes mellitus with neurological complications', 'IV', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('E11.5', 'Type 2 diabetes mellitus with peripheral circulatory complications', 'IV', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('E11.9', 'Type 2 diabetes mellitus without complications', 'IV', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('E28.2', 'Polycystic ovarian syndrome', 'IV', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('E46', 'Unspecified protein-energy malnutrition', 'IV', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('E66.9', 'Obesity, unspecified', 'IV', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('E78.5', 'Hyperlipidaemia, unspecified', 'IV', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('E86', 'Volume depletion', 'IV', 'N');

-- Chapter V: Mental and behavioural disorders
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('F10.2', 'Mental and behavioural disorders due to use of alcohol: dependence syndrome', 'V', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('F20.9', 'Schizophrenia, unspecified', 'V', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('F31.9', 'Bipolar affective disorder, unspecified', 'V', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('F32.9', 'Depressive episode, unspecified', 'V', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('F41.1', 'Generalized anxiety disorder', 'V', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('F41.9', 'Anxiety disorder, unspecified', 'V', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('F51.0', 'Nonorganic insomnia', 'V', 'N');

-- Chapter VI: Nervous system
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('G40.9', 'Epilepsy, unspecified', 'VI', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('G43.9', 'Migraine, unspecified', 'VI', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('G44.2', 'Tension-type headache', 'VI', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('G51.0', 'Bell palsy', 'VI', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('G62.9', 'Polyneuropathy, unspecified', 'VI', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('G80.9', 'Cerebral palsy, unspecified', 'VI', 'Y');

-- Chapter VII: Eye and adnexa
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('H10.1', 'Acute atopic conjunctivitis', 'VII', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('H10.9', 'Conjunctivitis, unspecified', 'VII', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('H25.9', 'Senile cataract, unspecified', 'VII', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('H40.9', 'Glaucoma, unspecified', 'VII', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('H52.4', 'Presbyopia', 'VII', 'Y');

-- Chapter VIII: Ear and mastoid
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('H60.9', 'Otitis externa, unspecified', 'VIII', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('H61.2', 'Impacted cerumen', 'VIII', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('H66.9', 'Otitis media, unspecified', 'VIII', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('H91.9', 'Hearing loss, unspecified', 'VIII', 'Y');

-- Chapter IX: Circulatory system
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('I10', 'Essential (primary) hypertension', 'IX', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('I11.9', 'Hypertensive heart disease without (congestive) heart failure', 'IX', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('I20.9', 'Angina pectoris, unspecified', 'IX', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('I25.9', 'Chronic ischaemic heart disease, unspecified', 'IX', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('I50.9', 'Heart failure, unspecified', 'IX', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('I64', 'Stroke, not specified as haemorrhage or infarction', 'IX', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('I69.4', 'Sequelae of stroke, not specified as haemorrhage or infarction', 'IX', 'Y');

-- Chapter X: Respiratory system
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('J00', 'Acute nasopharyngitis [common cold]', 'X', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('J01.9', 'Acute sinusitis, unspecified', 'X', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('J02.9', 'Acute pharyngitis, unspecified', 'X', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('J03.9', 'Acute tonsillitis, unspecified', 'X', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('J06.9', 'Acute upper respiratory infection, unspecified', 'X', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('J11.1', 'Influenza with other respiratory manifestations, virus not identified', 'X', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('J18.9', 'Pneumonia, unspecified', 'X', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('J20.9', 'Acute bronchitis, unspecified', 'X', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('J30.4', 'Allergic rhinitis, unspecified', 'X', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('J32.9', 'Chronic sinusitis, unspecified', 'X', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('J35.0', 'Chronic tonsillitis', 'X', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('J44.9', 'Chronic obstructive pulmonary disease, unspecified', 'X', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('J45.0', 'Predominantly allergic asthma', 'X', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('J45.9', 'Asthma, unspecified', 'X', 'Y');

-- Chapter XI: Digestive system
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('K02.9', 'Dental caries, unspecified', 'XI', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('K05.1', 'Chronic gingivitis', 'XI', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('K21.9', 'Gastro-oesophageal reflux disease without oesophagitis', 'XI', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('K25.9', 'Gastric ulcer, unspecified as acute or chronic, without haemorrhage or perforation', 'XI', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('K26.9', 'Duodenal ulcer, unspecified as acute or chronic, without haemorrhage or perforation', 'XI', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('K29.7', 'Gastritis, unspecified', 'XI', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('K30', 'Functional dyspepsia', 'XI', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('K35.8', 'Acute appendicitis, other and unspecified', 'XI', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('K40.9', 'Unilateral or unspecified inguinal hernia, without obstruction or gangrene', 'XI', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('K52.9', 'Noninfective gastroenteritis and colitis, unspecified', 'XI', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('K58.9', 'Irritable bowel syndrome without diarrhoea', 'XI', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('K59.0', 'Constipation', 'XI', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('K64.9', 'Haemorrhoids, unspecified', 'XI', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('K74.6', 'Other and unspecified cirrhosis of liver', 'XI', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('K76.0', 'Fatty (change of) liver, not elsewhere classified', 'XI', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('K80.2', 'Calculus of gallbladder without cholecystitis', 'XI', 'Y');

-- Chapter XII: Skin and subcutaneous tissue
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('L01.0', 'Impetigo [any organism] [any site]', 'XII', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('L02.9', 'Cutaneous abscess, furuncle and carbuncle, unspecified', 'XII', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('L03.9', 'Cellulitis, unspecified', 'XII', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('L20.9', 'Atopic dermatitis, unspecified', 'XII', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('L29.9', 'Pruritus, unspecified', 'XII', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('L30.9', 'Dermatitis, unspecified', 'XII', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('L40.0', 'Psoriasis vulgaris', 'XII', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('L50.9', 'Urticaria, unspecified', 'XII', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('L70.0', 'Acne vulgaris', 'XII', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('L91.0', 'Hypertrophic scar (keloid)', 'XII', 'N');

-- Chapter XIII: Musculoskeletal system
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('M06.9', 'Rheumatoid arthritis, unspecified', 'XIII', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('M10.9', 'Gout, unspecified', 'XIII', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('M16.9', 'Coxarthrosis, unspecified', 'XIII', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('M17.9', 'Gonarthrosis, unspecified', 'XIII', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('M25.5', 'Pain in joint', 'XIII', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('M47.9', 'Spondylosis, unspecified', 'XIII', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('M51.2', 'Other specified intervertebral disc displacement', 'XIII', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('M54.2', 'Cervicalgia', 'XIII', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('M54.4', 'Lumbago with sciatica', 'XIII', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('M54.5', 'Low back pain', 'XIII', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('M79.1', 'Myalgia', 'XIII', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('M81.9', 'Osteoporosis, unspecified', 'XIII', 'Y');

-- Chapter XIV: Genitourinary system
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('N10', 'Acute tubulo-interstitial nephritis', 'XIV', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('N18.9', 'Chronic kidney disease, unspecified', 'XIV', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('N20.0', 'Calculus of kidney', 'XIV', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('N30.0', 'Acute cystitis', 'XIV', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('N39.0', 'Urinary tract infection, site not specified', 'XIV', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('N40', 'Hyperplasia of prostate', 'XIV', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('N46', 'Male infertility', 'XIV', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('N63', 'Unspecified lump in breast', 'XIV', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('N73.9', 'Female pelvic inflammatory disease, unspecified', 'XIV', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('N76.0', 'Acute vaginitis', 'XIV', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('N83.2', 'Other and unspecified ovarian cysts', 'XIV', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('N91.2', 'Amenorrhoea, unspecified', 'XIV', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('N92.0', 'Excessive and frequent menstruation with regular cycle', 'XIV', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('N94.6', 'Dysmenorrhoea, unspecified', 'XIV', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('N95.1', 'Menopausal and female climacteric states', 'XIV', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('N97.9', 'Female infertility, unspecified', 'XIV', 'Y');

-- Chapter XV: Pregnancy and childbirth
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('O03.9', 'Spontaneous abortion, complete or unspecified, without complication', 'XV', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('O13', 'Gestational [pregnancy-induced] hypertension without significant proteinuria', 'XV', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('O14.9', 'Pre-eclampsia, unspecified', 'XV', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('O20.0', 'Threatened abortion', 'XV', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('O21.0', 'Mild hyperemesis gravidarum', 'XV', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('O23.4', 'Unspecified infection of urinary tract in pregnancy', 'XV', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('O24.4', 'Diabetes mellitus arising in pregnancy', 'XV', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('O98.6', 'Protozoal diseases complicating pregnancy, childbirth and the puerperium', 'XV', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('O99.0', 'Anaemia complicating pregnancy, childbirth and the puerperium', 'XV', 'N');

-- Chapter XVIII: Symptoms and signs
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('R00.2', 'Palpitations', 'XVIII', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('R04.0', 'Epistaxis', 'XVIII', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('R05', 'Cough', 'XVIII', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('R06.0', 'Dyspnoea', 'XVIII', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('R07.4', 'Chest pain, unspecified', 'XVIII', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('R10.4', 'Other and unspecified abdominal pain', 'XVIII', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('R11', 'Nausea and vomiting', 'XVIII', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('R21', 'Rash and other nonspecific skin eruption', 'XVIII', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('R30.0', 'Dysuria', 'XVIII', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('R42', 'Dizziness and giddiness', 'XVIII', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('R50.9', 'Fever, unspecified', 'XVIII', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('R51', 'Headache', 'XVIII', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('R53', 'Malaise and fatigue', 'XVIII', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('R55', 'Syncope and collapse', 'XVIII', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('R56.0', 'Febrile convulsions', 'XVIII', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('R63.4', 'Abnormal weight loss', 'XVIII', 'N');

-- Chapter XIX: Injury and poisoning
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('S00.9', 'Superficial injury of head, part unspecified', 'XIX', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('S01.9', 'Open wound of head, part unspecified', 'XIX', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('S06.0', 'Concussion', 'XIX', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('S52.5', 'Fracture of lower end of radius', 'XIX', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('S61.9', 'Open wound of wrist and hand, part unspecified', 'XIX', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('S93.4', 'Sprain and strain of ankle', 'XIX', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('T14.0', 'Superficial injury of unspecified body region', 'XIX', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('T14.1', 'Open wound of unspecified body region', 'XIX', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('T30.0', 'Burn of unspecified body region, unspecified degree', 'XIX', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('T63.0', 'Toxic effect of snake venom', 'XIX', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('T78.4', 'Allergy, unspecified', 'XIX', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('T88.7', 'Unspecified adverse effect of drug or medicament', 'XIX', 'N');

-- Chapter XXI: Factors influencing health status
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('Z00.0', 'General medical examination', 'XXI', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('Z00.1', 'Routine child health examination', 'XXI', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('Z02.1', 'Pre-employment examination', 'XXI', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('Z02.7', 'Issue of medical certificate', 'XXI', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('Z09.9', 'Follow-up examination after unspecified treatment for other conditions', 'XXI', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('Z11.4', 'Special screening examination for human immunodeficiency virus [HIV]', 'XXI', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('Z13.1', 'Special screening examination for diabetes mellitus', 'XXI', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('Z21', 'Asymptomatic human immunodeficiency virus [HIV] infection status', 'XXI', 'Y');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('Z30.0', 'General counselling and advice on contraception', 'XXI', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('Z34.9', 'Supervision of normal pregnancy, unspecified', 'XXI', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('Z48.0', 'Attention to dressings and sutures', 'XXI', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('Z71.3', 'Dietary counselling and surveillance', 'XXI', 'N');
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('Z76.0', 'Issue of repeat prescription', 'XXI', 'N');

-- Chapter XXII: Codes for special purposes
INSERT INTO jm_icd10_codes (icd10_code, description, chapter, chronic_flag) VALUES ('U07.1', 'COVID-19, virus identified', 'XXII', 'N');

--rollback DELETE FROM jm_icd10_codes WHERE icd10_code IN ('A01.0', 'A06.0', 'A09.9', 'A15.0', 'A16.9', 'A49.9', 'A53.9', 'A54.9', 'A56.0', 'A59.0', 'A96.2', 'B01.9', 'B02.9', 'B05.9', 'B15.9', 'B16.9', 'B18.1', 'B18.2', 'B24', 'B34.9', 'B35.4', 'B36.0', 'B37.0', 'B37.3', 'B50.0', 'B50.9', 'B54', 'B76.9', 'B77.9', 'B82.9', 'B86', 'C50.9', 'C61', 'D25.9', 'D50.9', 'D57.0', 'D57.1', 'D57.3', 'D64.9', 'E03.9', 'E04.9', 'E05.9', 'E10.9', 'E11.2', 'E11.4', 'E11.5', 'E11.9', 'E28.2', 'E46', 'E66.9', 'E78.5', 'E86', 'F10.2', 'F20.9', 'F31.9', 'F32.9', 'F41.1', 'F41.9', 'F51.0', 'G40.9', 'G43.9', 'G44.2', 'G51.0', 'G62.9', 'G80.9', 'H10.1', 'H10.9', 'H25.9', 'H40.9', 'H52.4', 'H60.9', 'H61.2', 'H66.9', 'H91.9', 'I10', 'I11.9', 'I20.9', 'I25.9', 'I50.9', 'I64', 'I69.4', 'J00', 'J01.9', 'J02.9', 'J03.9', 'J06.9', 'J11.1', 'J18.9', 'J20.9', 'J30.4', 'J32.9', 'J35.0', 'J44.9', 'J45.0', 'J45.9', 'K02.9', 'K05.1', 'K21.9', 'K25.9', 'K26.9', 'K29.7', 'K30', 'K35.8', 'K40.9', 'K52.9', 'K58.9', 'K59.0', 'K64.9', 'K74.6', 'K76.0', 'K80.2', 'L01.0', 'L02.9', 'L03.9', 'L20.9', 'L29.9', 'L30.9', 'L40.0', 'L50.9', 'L70.0', 'L91.0', 'M06.9', 'M10.9', 'M16.9', 'M17.9', 'M25.5', 'M47.9', 'M51.2', 'M54.2', 'M54.4', 'M54.5', 'M79.1', 'M81.9', 'N10', 'N18.9', 'N20.0', 'N30.0', 'N39.0', 'N40', 'N46', 'N63', 'N73.9', 'N76.0', 'N83.2', 'N91.2', 'N92.0', 'N94.6', 'N95.1', 'N97.9', 'O03.9', 'O13', 'O14.9', 'O20.0', 'O21.0', 'O23.4', 'O24.4', 'O98.6', 'O99.0', 'R00.2', 'R04.0', 'R05', 'R06.0', 'R07.4', 'R10.4', 'R11', 'R21', 'R30.0', 'R42', 'R50.9', 'R51', 'R53', 'R55', 'R56.0', 'R63.4', 'S00.9', 'S01.9', 'S06.0', 'S52.5', 'S61.9', 'S93.4', 'T14.0', 'T14.1', 'T30.0', 'T63.0', 'T78.4', 'T88.7', 'Z00.0', 'Z00.1', 'Z02.1', 'Z02.7', 'Z09.9', 'Z11.4', 'Z13.1', 'Z21', 'Z30.0', 'Z34.9', 'Z48.0', 'Z71.3', 'Z76.0', 'U07.1');
