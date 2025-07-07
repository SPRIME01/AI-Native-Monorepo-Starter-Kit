import { Tree, formatFiles } from "@nx/devkit";
import { execSync } from "child_process";

interface Schema {
  domain: string;
  name: string;
  type?: "application" | "core" | "infrastructure" | "shared";
  tags?: string;
}

export default async function (tree: Tree, schema: Schema) {
  const { domain, name, type = "application", tags } = schema;

  const projectName = `${domain}-${name}`;
  const directory = `libs/${domain}/${type}`;

  // Build tags: domain scope + type + any custom tags
  const defaultTags = `scope:${domain},type:${type}`;
  const allTags = tags ? `${defaultTags},${tags}` : defaultTags;

  console.log(
    `Generating ${projectName} in ${directory} with tags: ${allTags}`
  );

  execSync(
    `pnpm nx g @nx-python/nx-python:lib ${projectName} ` +
      `--directory="${directory}" ` +
      `--tags="${allTags}" ` +
      `--no-interactive`,
    { stdio: "inherit", cwd: tree.root }
  );

  await formatFiles(tree);
}
