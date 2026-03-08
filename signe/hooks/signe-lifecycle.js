#!/usr/bin/env node
// Signe Agent Lifecycle Hook
// Handles both SubagentStart and SubagentStop events
// Outputs to stdout (captured by Claude Code session)

const stdinTimeout = setTimeout(() => process.exit(0), 3000);
let input = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
  clearTimeout(stdinTimeout);
  try {
    const data = JSON.parse(input);
    const event = data.hook_event_name;
    const agentType = data.agent_type || 'unknown';
    const agentId = data.agent_id || 'unknown';

    // Only log signe-* agents (matcher handles this, but double-check)
    if (!agentType.startsWith('signe-')) {
      process.exit(0);
    }

    const timestamp = new Date().toISOString().slice(11, 19);

    if (event === 'SubagentStart') {
      console.log(`[Signe ${timestamp}] Started: ${agentType} (${agentId})`);
    } else if (event === 'SubagentStop') {
      console.log(`[Signe ${timestamp}] Stopped: ${agentType} (${agentId})`);
    }
  } catch (e) {
    // Silent fail -- don't break the session
  }
  process.exit(0);
});
