#!/usr/bin/env node
// Tabula-rasa Agent Lifecycle Hook
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

    // Debug mode: log raw event payload for schema verification
    if (process.env.TABULA_RASA_DEBUG === '1') {
      console.error(`[Tabula-rasa DEBUG] Raw event: ${JSON.stringify(data)}`);
    }

    const event = data.hook_event_name;
    const agentType = data.agent_type || 'unknown';
    const agentId = data.agent_id || 'unknown';

    // Warn when expected fields are missing (always-on, not debug-only)
    if (agentType === 'unknown' && agentId === 'unknown') {
      console.error(`[Tabula-rasa WARN] No agent_type/agent_id in event. Fields present: ${Object.keys(data).join(', ')}`);
    }

    // Only log tabula-rasa-* agents (matcher handles this, but double-check)
    if (!agentType.startsWith('tabula-rasa-') && agentType !== 'tabula-rasa') {
      process.exit(0);
    }

    // Workflow stage mapping for mode agents
    const workflowStages = {
      'tabula-rasa-researcher': 'Research',
      'tabula-rasa-planner': 'Planning',
      'tabula-rasa-detabula-rasar': 'Design',
      'tabula-rasa-overseer': 'Oversight'
    };

    const timestamp = new Date().toISOString().slice(11, 19);
    const stage = workflowStages[agentType];
    const stageLabel = stage ? ` [${stage} stage]` : '';

    if (event === 'SubagentStart') {
      console.log(`[Tabula-rasa ${timestamp}] Started: ${agentType} (${agentId})${stageLabel}`);
    } else if (event === 'SubagentStop') {
      console.log(`[Tabula-rasa ${timestamp}] Stopped: ${agentType} (${agentId})${stageLabel}`);
    }
  } catch (e) {
    // Silent fail -- don't break the session
  }
  process.exit(0);
});
