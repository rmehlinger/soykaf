/**
 * Created by Richard on 6/25/2017.
 */
let {casterTypes, raceNames, attributes} = require('./character.js');
let {MYSTIC_ADEPT, ADEPT, TECHNOMANCER, MAGICIAN, ASPECTED_MAGICIAN} = casterTypes;
let {HUMAN, ELF, DWARF, ORK, TROLL} = raceNames;
let {MAGIC, RESONANCE} = attributes;

exports= {
  metatype: {
    A: [
      {race: HUMAN, special: 9},
      {race: ELF, special: 8},
      {race: DWARF, special: 7},
      {race: ORK, special: 7},
      {race: TROLL, special: 5}
    ],
    B: [
      {race: HUMAN, special: 7},
      {race: ELF, special: 6},
      {race: DWARF, special: 4},
      {race: ORK, special: 4},
      {race: TROLL, special: 0}
    ],
    C: [
      {race: HUMAN, special: 5},
      {race: ELF, special: 4},
      {race: DWARF, special: 1},
      {race: ORK, special: 0}
    ],
    D: [
      {race: HUMAN, special: 3},
      {race: ELF, special: 0}
    ],
    E: [{race: HUMAN, special: 1}]
  },
  attributes: {A: [24], B: [20], C: [16], D: [14], E: [12]},
  skills: {
    A: [{skills: 46, groups: 10}],
    B: [{skills: 36, groups: 5}],
    C: [{skills: 28, groups: 2}],
    D: [{skills: 22, groups: 0}],
    E: [{skills: 18, groups: 0}]
  },
  resources: {A: [450000], B: [275000], C: [140000], D: [50000], E: [6000]},
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
    E: []
  }
};
