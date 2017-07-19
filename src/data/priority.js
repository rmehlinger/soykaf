let {MAGIC, RESONANCE, casterTypes, metatypeNames} = require('./character.js');
let {MYSTIC_ADEPT, ADEPT, TECHNOMANCER, MAGICIAN, ASPECTED_MAGICIAN} = casterTypes;
let {HUMAN, ELF, DWARF, ORK, TROLL} = metatypeNames;

module.exports = {
  metatype: {
    A: [
      {metatype: HUMAN, special: 9},
      {metatype: ELF, special: 8},
      {metatype: DWARF, special: 7},
      {metatype: ORK, special: 7},
      {metatype: TROLL, special: 5}
    ],
    B: [
      {metatype: HUMAN, special: 7},
      {metatype: ELF, special: 6},
      {metatype: DWARF, special: 4},
      {metatype: ORK, special: 4},
      {metatype: TROLL, special: 0}
    ],
    C: [
      {metatype: HUMAN, special: 5},
      {metatype: ELF, special: 4},
      {metatype: DWARF, special: 1},
      {metatype: ORK, special: 0}
    ],
    D: [
      {metatype: HUMAN, special: 3},
      {metatype: ELF, special: 0}
    ],
    E: [{metatype: HUMAN, special: 1}]
  },
  attributes: {A: [{points: 24}], B: [{points: 20}], C: [{points: 16}], D: [{points: 14}], E: [{points: 12}]},
  skills: {
    A: [{skills: 46, groups: 10}],
    B: [{skills: 36, groups: 5}],
    C: [{skills: 28, groups: 2}],
    D: [{skills: 22, groups: 0}],
    E: [{skills: 18, groups: 0}]
  },
  resources: {A: [{nuyen: 450000}], B: [{nuyen: 275000}], C: [{nuyen: 140000}], D: [{nuyen: 50000}], E: [{nuyen: 6000}]},
  magic: {
    A: [
      {
        type: MAGICIAN,
        skills: {
          quantity: 2,
          rating: 5,
          type: 'Magical'
        },
        spells: 10,
        attribute: {
          name: MAGIC,
          value: 6
        }
      },
      {
        type: MYSTIC_ADEPT,
        skills: {
          quantity: 2,
          rating: 5,
          type: 'Magical'
        },
        spells: 10,
        attribute: {
          name: MAGIC,
          value: 6
        }
      },
      {
        type: TECHNOMANCER,
        skills: {
          quantity: 2,
          rating: 5,
          type: 'Resonance'
        },
        complexForms: 5,
        attribute: {
          name: RESONANCE,
          value: 6
        }
      }
    ],
    B: [
      {
        type: MAGICIAN,
        skills: {
          quantity: 2,
          rating: 4,
          type: 'Magical'
        },
        spells: 7,
        attribute: {
          name: MAGIC,
          value: 4
        }
      },
      {
        type: MYSTIC_ADEPT,
        skills: {
          quantity: 2,
          rating: 4,
          type: 'Magical'
        },
        spells: 7,
        attribute: {
          name: MAGIC,
          value: 4
        }
      },
      {
        type: TECHNOMANCER,
        skills: {
          quantity: 2,
          rating: 4,
          type: 'Resonance'
        },
        complexForms: 2,
        attribute: {
          name: RESONANCE,
          value: 4
        }
      },
      {
        type: ADEPT,
        skills: {
          quantity: 1,
          rating: 4,
          type: 'Active'
        },
        attribute: {
          name: MAGIC,
          value: 6
        }
      },
      {
        type: ASPECTED_MAGICIAN,
        skills: {
          quantity: 1,
          type: 'Magical',
          rating: 4,
          group: true
        },
        attribute: {
          name: MAGIC,
          value: 5
        }
      }
    ],
    C: [
      {
        type: MAGICIAN,
        spells: 5,
        attribute: {
          name: MAGIC,
          value: 3
        }
      },
      {
        type: MYSTIC_ADEPT,
        spells: 5,
        attribute: {
          name: MAGIC,
          value: 3
        }
      },
      {
        type: TECHNOMANCER,
        attribute: {
          name: RESONANCE,
          value: 3
        },
        complex_forms: 1
      },
      {
        type: ADEPT,
        attribute: {
          name: MAGIC,
          value: 4
        },
        skills: {
          quantity: 1,
          rating: 2,
          type: 'Active'
        }
      },
      {
        type: ASPECTED_MAGICIAN,
        skills: {
          quantity: 1,
          rating: 3,
          type: "Magical",
          group: true
        },
        attribute: {
          name: MAGIC,
          value: 3
        }
      }
    ],
    D: [
      {
        type: ADEPT,
        attribute: {
          name: MAGIC,
          value: 2
        }
      },
      {
        type: ASPECTED_MAGICIAN,
        attribute: {
          name: MAGIC,
          value: 2
        }
      }
    ],
    E: [{type: "none"}]
  }
};
