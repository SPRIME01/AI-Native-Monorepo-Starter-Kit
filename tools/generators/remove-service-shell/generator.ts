// Placeholder Nx generator for remove-service-shell
import { Tree, formatFiles } from "@nx/devkit";

export default async function (tree: Tree, schema: { context: string }) {
  const { context } = schema;
  if (!context) throw new Error("Context name required");
  // TODO: Implement logic to remove service shell for the context
  // For now, just print what would happen
  console.log(
    `[remove-service-shell] Would remove service shell for context: ${context}`
  );
  await formatFiles(tree);
}
