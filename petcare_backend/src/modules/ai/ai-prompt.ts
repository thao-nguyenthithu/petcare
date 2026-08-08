// Prompt viết tiếng Anh 
export const TEN_CONG_CU = 'report_safety_gear';

export const MO_TA_CONG_CU =
  'Report what safety gear is visible on the dog in the photo.';

export const PROMPT_HE_THONG = [
  'You inspect check-in photos for a dog-walking service.',
  'Each photo shows ONE dog handed over to a walker.',
  'Report only gear you can actually see.',
  'A muzzle is a basket, mesh or fabric cover fitted over the snout and strapped behind the head.',
  'A collar, harness, bandana or head halter is NOT a muzzle.',
  'A leash counts only when it is clipped to the collar or harness and held or tied.',
  'A leash lying loose on the ground is ABSENT.',
  'Answer UNCLEAR whenever the gear is hidden, cropped, blurred or you would be guessing.',
  'Never resolve doubt in favour of the walker: a wrong PRESENT puts an unmuzzled dog on the street.',
].join(' ');

export const PROMPT_NGUOI_DUNG = [
  'Inspect this photo and report the dog and its gear.',
  'Set dog_visible to false when no dog is recognisable in the frame.',
  'Set image_clear to false when blur, darkness or distance stops you from judging the gear.',
  'Set confidence to your certainty about the muzzle and leash verdicts, from 0 to 1.',
].join(' ');

const GIA_TRI_GEAR = ['PRESENT', 'ABSENT', 'UNCLEAR'];

const TRUONG_BAT_BUOC = [
  'dog_visible',
  'image_clear',
  'muzzle',
  'leash',
  'confidence',
];

export const SCHEMA_ANTHROPIC = {
  type: 'object',
  properties: {
    dog_visible: { type: 'boolean' },
    image_clear: { type: 'boolean' },
    muzzle: { type: 'string', enum: GIA_TRI_GEAR },
    leash: { type: 'string', enum: GIA_TRI_GEAR },
    confidence: { type: 'number', minimum: 0, maximum: 1 },
  },
  required: TRUONG_BAT_BUOC,
  additionalProperties: false,
} as const;

export const SCHEMA_GEMINI = {
  type: 'OBJECT',
  properties: {
    dog_visible: { type: 'BOOLEAN' },
    image_clear: { type: 'BOOLEAN' },
    muzzle: { type: 'STRING', enum: GIA_TRI_GEAR },
    leash: { type: 'STRING', enum: GIA_TRI_GEAR },
    confidence: { type: 'NUMBER' },
  },
  required: TRUONG_BAT_BUOC,
  propertyOrdering: TRUONG_BAT_BUOC,
} as const;
