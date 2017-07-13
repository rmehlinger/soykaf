let addictionCondition = (doses) => {
  return `During withdrawal; to Physical tests if physically dependent or mental tests if psyhchologically dependent. 
 Requires ${doses} doses/hrs of habit-related activity to satisfy.`;
};

module.exports = {
  positive: [
    {"name": "Ambidextrous", "karma": 4},
    {"name": "Analytical Mind", "karma": 5, "effect": { "optional": true, "bonus": 2, "test": "Logic"}},
    {"name": "Aptitude", "karma": 14, "select": "skill", "effect": {"limit": 1}},
    {"name": "Astral Chameleon", "karma": 10},
    {"name": "Bilingual", "karma": 5, "select": "skill:language"},
    {"name": "Blandness", "karma": 8},
    {"name": "Catlike", "karma": 7, "effect": {"skill": ["stealth"], "bonus": 2}},
    {
      "name": "Codeslinger",
      "karma": 10,
      "select": "matrix action",
      "effect": {
        "bonus": 2
      }
    },
    {
      "name": "Doublejointed",
      "karma": 6,
      "effect": {
        "skill": [
          "Escape Artist"
        ],
        "bonus": 2
      }
    },
    {
      "name": "Exceptional Attribute",
      "karma": 14,
      "select": "attribute",
      "effect": {
        "limit": 1
      }
    },
    {
      "name": "First Impression",
      "karma": 11,
      "effect": {
        "bonus": 2,
        "optional": true,
        "test": "Social"
      }
    },
    {
      "name": "Focused Concentration",
      "karma": 4,
      "multiple": 6
    },
    {
      "name": "Gearhead",
      "karma": 11,
      "effect": {
        "bonus": 2,
        "optional": true,
        "test": "difficult maneuvers",
        "misc": "+1 Handling Modifier OR +20 percent speed for vehicles/drones"
      }
    },
    {
      "name": "Guts",
      "karma": 10,
      "effect": {
        "bonus": 2,
        "test": "resist fear/intimidation"
      }
    },
    {
      "name": "High Pain Tolerance",
      "karma": 7,
      "multiple": 3,
      "effect": {
        "shiftWoundPenalty": 1
      }
    },
    {
      "name": "Home Ground",
      "karma": 10,
      "effect": {
        "bonus": 2,
        "optional": true
      },
      "select": [
        {
          "name": "Astral Acclimation",
          "description": "ignore 2 points background count"
        },
        {
          "name": "You Know a Guy",
          "description": "+2 street cred for Negotiation with people from home ground"
        },
        {
          "name": "Digital Turf",
          "description": "+2 bonus to Matrix tests while in Home Ground Host"
        },
        {
          "name": "The Transporter",
          "description": "+2 dice pool to evasion tests on Home Ground"
        },
        {
          "name": "On the Lam",
          "description": "+2 dice pool to intuition + street knowledge skill to find a bolthole"
        },
        {
          "name": "Street Politics",
          "description": "+2 dice pool for knowledge tests relating to gangs or their operations"
        }
      ]
    },
    {
      "name": "Human Looking",
      "karma": 6
    },
    {"name": "Indomitable (Physical)", "karma": 8, "effect": {"bonus": 1}},
    {"name": "Indomitable (Mental)", "karma": 8, "effect": {"bonus": 1}},
    {"name": "Indomitable (Social)", "karma": 8, "effect": {"bonus": 1}},
    {
      "name": "Juryrigger",
      "karma": 10,
      "effect": {
        "bonus": 2,
        "optional": true
      }
    },
    {
      "name": "Lucky",
      "karma": 12,
      "effect": {
        "attribute": "Edge",
        "limit": 1
      }
    },
    {
      "name": "Magic Resistance",
      "karma": 6,
      "multiple": 4
    },
    {
      "name": "Mentor Spirit",
      "karma": 5,
      "playerDescribed": true
    },
    {
      "name": "Natural Athlete",
      "karma": 7,
      "effect": {
        "skill": [
          "Running",
          "Gymnastics"
        ],
        "bonus": 2
      }
    },
    {
      "name": "Natural Hardening",
      "karma": 10
    },
    {
      "name": "Natural Immunity, natural",
      "karma": 4,
      "playerDescribed": true
    },
    {
      "name": "Natural Immunity, synthetic",
      "karma": 4,
      "playerDescribed": true
    },
    {
      "name": "Photographic Memory",
      "karma": 6,
      "effect": {
        "bonus": 2,
        "test": "Memory"
      }
    },
    {
      "name": "Quick Healer",
      "karma": 3,
      "effect": {
        "bonus": 2,
        "test": "Healing"
      }
    },
    {
      "name": "Resist Pathogens",
      "karma": 4,
      "effect": {
        "bonus": 1,
        "test": "Resist Pathogens"
      }
    },
    {
      "name": "Resist Toxins",
      "karma": 4,
      "effect": {
        "bonus": 1,
        "test": "Resist Toxins"
      }
    },
    {
      "name": "Spirit Affinity",
      "karma": 7,
      "select": [
        {name: "air"},
        {name: "earth"},
        {name: "water"},
        {name: "fire"},
        {name: "beasts"},
        {name: "man"}
      ],
      "effect": {
        "bonus": 1,
        "test": "binding"
      },
      "description": "+1 service from selected spirit type; spirits of this type more reluctant to attack."
    },
    {
      "name": "Toughness",
      "karma": 9,
      "effect": {
        "bonus": 1,
        "test": "Damage Resistance"
      }
    },
    {
      "name": "Will to Live",
      "karma": 3,
      "multiple": 3,
      "effect": {},
      "description": "Character sustains additional damage before dying"
    }
  ],
  negative: [
    {
      "name": "Addiction, Mild",
      "karma": 4,
      "effect": {
        "bonus": -2
      },
      "description": "During withdrawal; to Physical tests if physically dependent or mental tests if psyhchologically dependent.\n Requires 1 doses/hrs of habit-related activity to satisfy."
    },
    {
      "name": "Addiction, Moderate",
      "karma": 9,
      "effect": {
        "bonus": -4
      },
      "description": "During withdrawal; to Physical tests if physically dependent or mental tests if psyhchologically dependent.\n Requires 1 doses/hrs of habit-related activity to satisfy."
    },
    {
      "name": "Addiction, Severe",
      "karma": 20,
      "effect": [
        {
          "bonus": -4,
          "other": "During withdrawal; to Physical tests if physically dependent or mental tests if psyhchologically dependent.\n Requires 2 doses/hrs of habit-related activity to satisfy."
        },
        {
          "bonus": -2,
          "test": "Social"
        }
      ]
    },
    {
      "name": "Addiction, Burnout",
      "karma": 25,
      "effect": [
        {
          "bonus": -6,
          "other": "During withdrawal; to Physical tests if physically dependent or mental tests if psyhchologically dependent.\n Requires 3 doses/hrs of habit-related activity to satisfy."
        },
        {
          "bonus": -3,
          "test": "Social"
        }
      ]
    },
    {
      "name": "Allergy, Mild, Uncommon",
      "karma": 5,
      "effect": {
        "bonus": -1,
        "optional": true,
        "test": "Resistance"
      }
    },
    {
      "name": "Allergy, Mild, Common",
      "karma": 10,
      "effect": {
        "bonus": -1,
        "optional": true,
        "test": "Resistance"
      }
    },
    {
      "name": "Allergy, Moderate, Unommon",
      "karma": 10,
      "effect": {
        "bonus": -2,
        "optional": true,
        "test": "Resistance"
      }
    },
    {
      "name": "Allergy, Moderate, Common",
      "karma": 15,
      "effect": {
        "bonus": -2,
        "optional": true,
        "test": "Resistance"
      }
    },
    {
      "name": "Allergy, Severe, Unommon",
      "karma": 15,
      "effect": {
        "bonus": -3,
        "optional": true,
        "test": "Resistance"
      }
    },
    {
      "name": "Allergy, Severe, Common",
      "karma": 20,
      "effect": {
        "bonus": -3,
        "optional": true,
        "test": "Resistance"
      }
    },
    {
      "name": "Allergy, Extreme, Unommon",
      "karma": 20,
      "effect": {
        "bonus": -4,
        "optional": true,
        "test": "Resistance"
      }
    },
    {
      "name": "Allergy, Extreme, Common",
      "karma": 25,
      "effect": {
        "bonus": -4,
        "optional": true,
        "test": "Resistance"
      }
    },
    {
      "name": "Astral Beacon",
      "karma": 10
    },
    {
      "name": "Bad Luck",
      "karma": 12,
      "effect": {},
      "description": "Roll 1d6 when spending Edge. If you roll a one, receive opposite of intended effect."
    },
    {
      "name": "Bad Rep",
      "karma": 7,
      "effect": {},
      "description": "Start with three points notoriety; can only be decreased by resolving source."
    },
    {
      "name": "Code of Honor",
      "karma": 15,
      "playerDescribed": true,
      "effect": {},
      "description": "Cannot kill member of protected group."
    },
    {
      "name": "Codeblock",
      "karma": 10,
      "select": "matrix action",
      "effect": {
        "bonus": -2
      }
    },
    {
      "name": "Combat Paralysis",
      "karma": 12
    },
    {
      "name": "Dependents",
      "karma": 3,
      "multiple": 3
    },
    {
      "name": "Distinctive Style",
      "karma": 5
    },
    {
      "name": "Elf Poser",
      "karma": 6
    },
    {
      "name": "Gremlins",
      "karma": 4,
      "multiple": 4,
      "effect": {},
      "description": "one fewer rolled 1 necessary to glitch per level"
    },
    {
      "name": "Incompetent",
      "karma": 5,
      "select": "skill group",
      "effect": {},
      "description": "Always unaware for all skills in group"
    },
    {
      "name": "Insomnia, moderate",
      "karma": 10,
      "effect": {},
      "description": "if character fails Int + Will (4) test, twice as long to recover stun damage by resting.\n      Edge cannot refresh for up to another 24 hours."
    },
    {
      "name": "Insomnia, severe",
      "karma": 10,
      "effect": {},
      "description": "if character fails Int + Will (4) test, no stun damage recovered by resting.\n      Edge cannot refresh for up to another 24 hours."
    },
    {
      "name": "Loss of Confidence",
      "karma": 10,
      "select": "skill",
      "effect": {
        "bonus": -2
      },
      "description": "Skill must be +4 or higher"
    },
    {
      "name": "Low Pain Tolerance",
      "karma": 9,
      "effect": {},
      "description": "-1 wound modifier for every 2 boxes cumulative damage, rather than 3"
    },
    {
      "name": "Ork Poser",
      "karma": 6
    },
    {
      "name": "Prejudiced, Specific, Biased",
      "karma": 3,
      "playerDescribed": true,
      "effect": {
        "bonus": -2,
        "optional": true,
        "test": "Social, against target of prejudice"
      }
    },
    {
      "name": "Prejudiced, Common, Biased",
      "karma": 5,
      "playerDescribed": true,
      "effect": {
        "bonus": -2,
        "optional": true,
        "test": "Social, against target of prejudice"
      }
    },
    {
      "name": "Prejudiced, Specific, Outspoken",
      "karma": 5,
      "playerDescribed": true,
      "effect": {
        "bonus": -2,
        "optional": true,
        "test": "Social, against target of prejudice"
      }
    },
    {
      "name": "Prejudiced, Common, Outspoken",
      "karma": 7,
      "playerDescribed": true,
      "effect": {
        "bonus": -2,
        "optional": true,
        "test": "Social, against target of prejudice"
      }
    },
    {
      "name": "Prejudiced, Specific, Radical",
      "karma": 8,
      "playerDescribed": true,
      "effect": {
        "bonus": -2,
        "optional": true,
        "test": "Social, against target of prejudice"
      }
    },
    {
      "name": "Prejudiced, Common, Radical",
      "karma": 10,
      "playerDescribed": true,
      "effect": {
        "bonus": -2,
        "optional": true,
        "test": "Social, against target of prejudice"
      }
    },
    {
      "name": "Scorched",
      "karma": 10,
      "playerDescribed": true
    },
    {
      "name": "Sensitive System",
      "karma": 12
    },
    {
      "name": "Simsense Vertigo",
      "karma": 5,
      "effect": {
        "bonus": -2,
        "test": "Anything involving AR, VR, or simsense"
      }
    },
    {
      "name": "Sinner (National)",
      "karma": 5
    },
    {
      "name": "Sinner (Criminal)",
      "karma": 10
    },
    {
      "name": "Sinner (Corporate Limited)",
      "karma": 15
    },
    {
      "name": "Sinner (Corporate)",
      "karma": 25
    },
    {
      "name": "Social Stress",
      "karma": 8,
      "playerDescribed": true,
      "effect": {},
      "description": "One fewer 1 required to glitch if triggered."
    },
    {
      "name": "Spirit Bane",
      "karma": 7,
      "select": [
        {name: "air"},
        {name: "earth"},
        {name: "water"},
        {name: "fire"},
        {name: "beasts"},
        {name: "man"}
      ]
    },
    {
      "name": "Uncouth",
      "karma": 14,
      "effect": {
        "test": "Social (resist acting improperly)",
        "bonus": -2
      },
      "description": "Unaware in untrained social skills. Cannot learn social skill groups. Double cost to learn social skills."
    },
    {
      "name": "Uneducated",
      "karma": 8,
      "effect": {},
      "description": "Unaware in Technical, Academic Knowledge, and Proessional Knowledge. Karma costs doubled to learn these skills."
    },
    {
      "name": "Unsteady Hands",
      "karma": 7,
      "effect": {
        "bonus": -2,
        "test": "Agility"
      },
      "description": "If character has failed Agi + Body = 4 test following stressful encounter."
    },
    {
      "name": "Weak Immune System",
      "karma": 10,
      "effect": {},
      "description": "Any disease gains +2 power for every resistance test."
    }
  ]
};