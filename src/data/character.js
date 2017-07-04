let HUMAN = 'human', ELF = 'elf', DWARF = 'dwarf', ORK = 'ork', TROLL = 'troll';

// attributes
// special
let EDGE = 'edge', MAGIC = 'magic', RESONANCE = 'resonance';
// physical
let BODY = 'body', AGI = 'agility', REA = 'reaction', STR = 'strength';
// mental
let WIL = 'willpower', LOG = 'logic', INT = 'intuition', CHA = 'charisma';
let attributeNames = [BODY, AGI, REA, STR, WIL, LOG, INT, CHA];

module.exports = {
  casterTypes: {
    MYSTIC_ADEPT: 'mystic_adept',
    ADEPT: 'adept',
    TECHNOMANCER: 'technomancer',
    MAGICIAN: 'magician',
    ASPECTED_MAGICIAN: 'aspected_magician'
  },
  metatypeNames: {HUMAN, ELF, DWARF, ORK, TROLL},
  attributeNames, EDGE, MAGIC, RESONANCE,
  metatypeStats: {
    human: {
      racial: [],
      vision: "Normal",
      costMultiplier: 1.0,
      attributes: {
        [EDGE]: {
          base: 2,
          limit: 7
        }
      }
    },
    elf: {
      racial: [],
      vision: "Low-Light",
      costMultiplier: 1.0,
      attributes: {
        [AGI]: {base: 2, limit: 7},
        [CHA]: {base: 3, limit: 8}
      }
    },
    dwarf: {
      racial: ["+2 dice for pathogen/toxin resistance", "+20% lifestyle cost"],
      vision: "Thermographic",
      costMultiplier: 1.2,
      attributes: {
        [BODY]: {base: 3, limit: 8},
        [REA]: {base: 1, limit: 5},
        [STR]: {base: 3, limit: 8},
        [WIL]: {base: 2, limit: 7}
      }
    },
    ork: {
      racial: [],
      vision: "Low-Light",
      costMultiplier: 1.0,
      attributes: {
        [BODY]: {base: 4, limit: 9},
        [STR]: {base: 3, limit: 8},
        [LOG]: {base: 1, limit: 5},
        [CHA]: {base: 1, limit: 5}
      }
    },
    troll: {
      racial: ["+1 Reach", "+1 dermal armor", "+100% gear/lifestyle costs"],
      vision: "Thermographic",
      costMultiplier: 2.0,
      attributes: {
        [BODY]: {base: 5, limit: 10},
        [AGI]: {base: 1, limit: 5},
        [STR]: {base: 5, limit: 10},
        [LOG]: {base: 1, limit: 5},
        [INT]: {base: 1, limit: 5},
        [CHA]: {base: 1, limit: 4}
      }
    }
  }
};