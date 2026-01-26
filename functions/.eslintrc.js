module.exports = {
  env: {
    es6: true,
    node: true,
  },
  parserOptions: {
    "ecmaVersion": 2018,
  },
  extends: [
    "eslint:recommended",
  ],
  rules: {
    "no-restricted-globals": ["warn", "name", "length"],
    "prefer-arrow-callback": "warn",
    "quotes": "off",
    "indent": "off",
    "max-len": "off",
    "require-jsdoc": "off",
    "object-curly-spacing": "off",
    "comma-dangle": "off",
  },
  overrides: [
    {
      files: ["**/*.spec.*"],
      env: {
        mocha: true,
      },
      rules: {},
    },
  ],
  globals: {},
};
