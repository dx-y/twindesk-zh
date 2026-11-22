// Checks the Simplified Chinese layer of a prepared source tree:
//   node scripts/verify-zh.js <source dir>
// Loads shared/i18n.js + shared/lang/zh-extra.js and makes sure every catalog key that is
// Chinese-only resolves to Chinese, and that other locales are left untouched.
'use strict';
const path = require('path');
const fs = require('fs');

const src = path.resolve(process.argv[2] || '.');
const i18nPath = path.join(src, 'shared', 'i18n.js');
const extraPath = path.join(src, 'shared', 'lang', 'zh-extra.js');
for (const p of [i18nPath, extraPath]) {
  if (!fs.existsSync(p)) {
    console.error('missing: ' + p);
    process.exit(2);
  }
}

const i18n = require(i18nPath);
if (typeof i18n.create !== 'function') {
  console.error('shared/i18n.js has no create(); unexpected upstream change');
  process.exit(2);
}

let extra = globalThis.TwinDeskZhExtra;
if (!extra) {
  require(extraPath);
  extra = globalThis.TwinDeskZhExtra;
}
if (!extra) {
  console.error('zh-extra.js did not expose TwinDeskZhExtra');
  process.exit(2);
}

const keys = Object.keys(extra);
const zh = i18n.create('zh-CN');
const en = i18n.create('en');

// Values that are meant to stay in Latin script: product names, protocol names, key names, units.
const KEEP = new Set([
  'AirPlay', 'AirPlay · {name}', 'Esc', 'esc', 'TwinDesk', 'TwinDesk Web', 'TwinDesk {version}', 'Windows',
  'App IDs', 'the Mac'
]);

// Chinese, or Chinese punctuation only (e.g. "Apple ID：{account}") counts as localized.
const LOCALIZED = /[\u4e00-\u9fff\u3000-\u303f\uff00-\uffef]/;

let chinese = 0;
const kept = [];
const wrong = [];
for (const key of keys) {
  const out = String(zh.t(key));
  if (LOCALIZED.test(out)) { chinese++; continue; }
  if (KEEP.has(key) || KEEP.has(out)) { kept.push(key); continue; }
  wrong.push(key + '  =>  ' + out);
}

const enProbe = String(en.t('Save'));
const enOk = enProbe === 'Save';

console.log('catalog keys      : ' + keys.length);
console.log('resolved Chinese  : ' + chinese);
console.log('kept in Latin     : ' + kept.length + (kept.length ? ' (' + kept.join(', ') + ')' : ''));
console.log('still English     : ' + wrong.length);
console.log('english unaffected: ' + (enOk ? 'yes' : 'no, en.t("Save") = ' + enProbe));

if (wrong.length) {
  console.log('\n--- unexpected English ---');
  for (const w of wrong.slice(0, 40)) console.log(w);
  if (wrong.length > 40) console.log('... ' + (wrong.length - 40) + ' more');
}
process.exit(wrong.length === 0 && enOk ? 0 : 1);
