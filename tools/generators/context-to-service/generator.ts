// Placeholder Nx generator for context-to-service
import { Tree, formatFiles } from "@nx/devkit";

export default async function (
  tree: Tree,
  schema: { context: string; transport?: string }
) {
  const { context, transport = "fastapi" } = schema;
  if (!context) throw new Error("Context name required");
  // TODO: Implement logic to scaffold service shell for the context
  // For now, just print what would happen
  console.log(
    `[context-to-service] Would scaffold service for context: ${context} with transport: ${transport}`
  );
  await formatFiles(tree);
}
