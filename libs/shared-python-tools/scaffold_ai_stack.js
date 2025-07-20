// scaffold_ai_stack.js
// Usage: node scaffold_ai_stack.js <domain>
// Prints recommended AI/ML dependencies for the given domain

const { AI_PRESETS } = require("./ai_presets");

const domain = process.argv[2];
if (!domain) {
  console.error("Usage: node scaffold_ai_stack.js <domain>");
  process.exit(1);
}

console.log(`\nRecommended AI/ML dependencies for domain: ${domain}\n`);
for (const [category, pkgs] of Object.entries(AI_PRESETS)) {
  console.log(`- ${category}:`);
  pkgs.forEach((pkg) => console.log(`    - ${pkg}`));
}
console.log("\nAdd these to your requirements or pyproject as needed.");
