/**
 * video plugin for OpenCode.ai
 *
 * Auto-registers the skills directory via the config hook (no symlinks needed).
 *
 * This plugin injects no per-session bootstrap context. The skill is
 * explicitly invoked - you reach for it when you want a motion graphic
 * rendered from a recipe - so OpenCode's native `skill` tool discovering it is
 * all that is needed. Every run writes a project directory and spends minutes
 * of render time, so a preamble nudging the model toward it unprompted would
 * be actively harmful.
 */

import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

export const VideoPlugin = async () => {
  const videoSkillsDir = path.resolve(__dirname, '../../skills');

  return {
    // Inject skills path into live config so OpenCode discovers the video
    // skills without requiring manual symlinks or config file edits.
    // This works because Config.get() returns a cached singleton - modifications
    // here are visible when skills are lazily discovered later.
    config: async (config) => {
      config.skills = config.skills || {};
      config.skills.paths = config.skills.paths || [];
      if (!config.skills.paths.includes(videoSkillsDir)) {
        config.skills.paths.push(videoSkillsDir);
      }
    },
  };
};
