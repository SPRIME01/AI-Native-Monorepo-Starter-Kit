import { Tree, formatFiles } from "@nx/devkit";
import { execSync } from "child_process";
import * as fs from "fs";

interface Schema {
  domains: string;
  type?: "application" | "core" | "infrastructure" | "shared";
  suffix?: string;
}

export default async function (tree: Tree, schema: Schema) {
  const { domains, type = "application", suffix = "service" } = schema;
  const domainList = domains.split(",").map((d) => d.trim());

  console.log(
    `Generating ${type} libraries for domains: ${domainList.join(", ")}`
  );

  domainList.forEach((domain) => {
    // Read MECE lists if present
    const defDir = `project-definitions/${domain}`;
    if (fs.existsSync(defDir)) {
      [
        "entities",
        "services",
        "ports",
        "libs",
        "apps",
        "tools",
        "docker",
      ].forEach((cat) => {
        const listFile = `${defDir}/${cat}.txt`;
        if (fs.existsSync(listFile)) {
          const items = fs
            .readFileSync(listFile, "utf-8")
            .split("\n")
            .map((l) => l.trim())
            .filter(Boolean);
          items.forEach((name) => {
            // Example: generate a lib for each entity/service/port
            if (["entities", "services", "ports"].includes(cat)) {
              const projectName = `${domain}-${name}`;
              const directory = `libs/${domain}/${cat}`;
              const tags = `scope:${domain},type:${cat}`;
              execSync(
                `pnpm nx g @nx-python/nx-python:lib ${projectName} ` +
                  `--directory="${directory}" ` +
                  `--tags="${tags}" ` +
                  `--no-interactive`,
                { stdio: "inherit", cwd: tree.root }
              );
            }
            // Extend for other categories as needed
          });
        }
      });
    } else {
      // Fallback: original behavior
      const projectName = `${domain}-${suffix}`;
      const directory = `libs/${domain}/${type}`;
      const tags = `scope:${domain},type:${type}`;
      execSync(
        `pnpm nx g @nx-python/nx-python:lib ${projectName} ` +
          `--directory="${directory}" ` +
          `--tags="${tags}" ` +
          `--no-interactive`,
        { stdio: "inherit", cwd: tree.root }
      );
    }
  });

  await formatFiles(tree);
}
