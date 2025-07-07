import { Tree, formatFiles } from "@nx/devkit";
import { execSync } from "child_process";

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
    const projectName = `${domain}-${suffix}`;
    const directory = `libs/${domain}/${type}`;
    const tags = `scope:${domain},type:${type}`;

    console.log(`Creating ${projectName} in ${directory}`);

    execSync(
      `pnpm nx g @nx-python/nx-python:lib ${projectName} ` +
        `--directory="${directory}" ` +
        `--tags="${tags}" ` +
        `--no-interactive`,
      { stdio: "inherit", cwd: tree.root }
    );
  });

  await formatFiles(tree);
}
