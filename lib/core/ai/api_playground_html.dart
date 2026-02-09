/// Embedded HTML for the API Playground — a Swagger-like UI served at the
/// root of the AI host server.  Users enter an access code shown in the
/// Flutter Gateway UI to unlock the playground.
library;

const String apiPlaygroundHtml = r'''
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Prism API Playground</title>
<style>
  :root {
    --bg: #0f1117;
    --surface: #1a1d27;
    --surface2: #22262f;
    --border: #2a2e3a;
    --border-hover: #3a3f4f;
    --text: #e4e6ed;
    --text2: #8b8fa3;
    --accent: #6366f1;
    --accent-hover: #818cf8;
    --accent-dim: rgba(99,102,241,.12);
    --green: #10b981;
    --green-dim: rgba(16,185,129,.12);
    --blue: #3b82f6;
    --blue-dim: rgba(59,130,246,.12);
    --orange: #f59e0b;
    --orange-dim: rgba(245,158,11,.12);
    --red: #ef4444;
    --red-dim: rgba(239,68,68,.12);
    --radius: 10px;
    --font: 'Segoe UI', system-ui, -apple-system, sans-serif;
    --mono: 'Cascadia Code', 'Fira Code', 'JetBrains Mono', 'Consolas', monospace;
  }
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body { font-family: var(--font); background: var(--bg); color: var(--text); min-height: 100vh; }
  button { cursor: pointer; font-family: var(--font); border: none; }
  input, textarea, select { font-family: var(--font); }

  /* ── Scrollbar ── */
  ::-webkit-scrollbar { width: 6px; height: 6px; }
  ::-webkit-scrollbar-track { background: transparent; }
  ::-webkit-scrollbar-thumb { background: var(--border); border-radius: 3px; }
  ::-webkit-scrollbar-thumb:hover { background: var(--border-hover); }

  /* ── Auth Screen ── */
  #auth-screen {
    display: flex; align-items: center; justify-content: center;
    min-height: 100vh; padding: 20px;
  }
  .auth-card {
    background: var(--surface); border: 1px solid var(--border);
    border-radius: 16px; padding: 40px; max-width: 400px; width: 100%;
    text-align: center;
  }
  .auth-logo {
    width: 56px; height: 56px; background: var(--accent-dim);
    border-radius: 14px; display: flex; align-items: center; justify-content: center;
    margin: 0 auto 20px; font-size: 24px;
  }
  .auth-title { font-size: 22px; font-weight: 700; margin-bottom: 6px; }
  .auth-sub { color: var(--text2); font-size: 14px; margin-bottom: 28px; line-height: 1.5; }
  .auth-input {
    width: 100%; padding: 14px 16px; background: var(--surface2);
    border: 1px solid var(--border); border-radius: var(--radius);
    color: var(--text); font-size: 20px; text-align: center;
    letter-spacing: 8px; font-weight: 600; outline: none;
    transition: border-color .2s;
  }
  .auth-input:focus { border-color: var(--accent); }
  .auth-input::placeholder { letter-spacing: 2px; font-size: 14px; font-weight: 400; }
  .auth-btn {
    width: 100%; padding: 13px; background: var(--accent); color: #fff;
    border-radius: var(--radius); font-size: 15px; font-weight: 600;
    margin-top: 16px; transition: background .2s;
  }
  .auth-btn:hover { background: var(--accent-hover); }
  .auth-btn:disabled { opacity: .5; cursor: not-allowed; }
  .auth-error {
    color: var(--red); font-size: 13px; margin-top: 12px;
    min-height: 18px;
  }

  /* ── Main Layout ── */
  #main-screen { display: none; }
  .topbar {
    background: var(--surface); border-bottom: 1px solid var(--border);
    padding: 14px 24px; display: flex; align-items: center; gap: 12px;
    position: sticky; top: 0; z-index: 10;
  }
  .topbar-logo {
    width: 32px; height: 32px; background: var(--accent-dim);
    border-radius: 8px; display: flex; align-items: center; justify-content: center;
    font-size: 16px;
  }
  .topbar-title { font-size: 16px; font-weight: 700; }
  .topbar-badge {
    font-size: 11px; padding: 3px 8px; border-radius: 6px;
    font-weight: 600;
  }
  .badge-connected { background: var(--green-dim); color: var(--green); }
  .badge-disconnected { background: var(--red-dim); color: var(--red); }
  .topbar-spacer { flex: 1; }
  .topbar-url { color: var(--text2); font-size: 12px; font-family: var(--mono); }
  .disconnect-btn {
    padding: 7px 14px; background: var(--surface2); border: 1px solid var(--border);
    border-radius: 8px; color: var(--text2); font-size: 12px; font-weight: 500;
    transition: all .2s;
  }
  .disconnect-btn:hover { border-color: var(--red); color: var(--red); }

  .main-content { max-width: 900px; margin: 0 auto; padding: 24px; }

  /* ── Server Info ── */
  .server-info {
    background: var(--surface); border: 1px solid var(--border);
    border-radius: var(--radius); padding: 18px 20px;
    margin-bottom: 20px; display: flex; align-items: center; gap: 16px;
    flex-wrap: wrap;
  }
  .info-item { display: flex; align-items: center; gap: 6px; }
  .info-label { color: var(--text2); font-size: 12px; }
  .info-value { font-size: 13px; font-weight: 600; }

  /* ── Endpoint Card ── */
  .endpoint-card {
    background: var(--surface); border: 1px solid var(--border);
    border-radius: var(--radius); margin-bottom: 16px; overflow: hidden;
    transition: border-color .2s;
  }
  .endpoint-card:hover { border-color: var(--border-hover); }
  .endpoint-header {
    padding: 16px 20px; display: flex; align-items: center; gap: 12px;
    cursor: pointer; user-select: none;
  }
  .method-badge {
    font-size: 11px; font-weight: 700; padding: 4px 10px;
    border-radius: 6px; font-family: var(--mono); min-width: 52px;
    text-align: center; text-transform: uppercase;
  }
  .method-get { background: var(--green-dim); color: var(--green); }
  .method-post { background: var(--blue-dim); color: var(--blue); }
  .method-put { background: var(--orange-dim); color: var(--orange); }
  .method-delete { background: var(--red-dim); color: var(--red); }
  .endpoint-path { font-family: var(--mono); font-size: 14px; font-weight: 600; }
  .endpoint-desc { color: var(--text2); font-size: 13px; margin-left: auto; }
  .endpoint-chevron {
    color: var(--text2); transition: transform .2s; font-size: 12px;
  }
  .endpoint-card.open .endpoint-chevron { transform: rotate(180deg); }
  .endpoint-body {
    border-top: 1px solid var(--border); padding: 20px;
    display: none;
  }
  .endpoint-card.open .endpoint-body { display: block; }

  /* ── Form Elements ── */
  .form-group { margin-bottom: 16px; }
  .form-label {
    font-size: 12px; font-weight: 600; color: var(--text2);
    margin-bottom: 6px; display: block; text-transform: uppercase;
    letter-spacing: .5px;
  }
  .form-input {
    width: 100%; padding: 10px 12px; background: var(--surface2);
    border: 1px solid var(--border); border-radius: 8px;
    color: var(--text); font-size: 13px; outline: none;
    transition: border-color .2s;
  }
  .form-input:focus { border-color: var(--accent); }
  .form-select {
    width: 100%; padding: 10px 12px; background: var(--surface2);
    border: 1px solid var(--border); border-radius: 8px;
    color: var(--text); font-size: 13px; outline: none;
    appearance: none; cursor: pointer;
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%238b8fa3' stroke-width='2'%3E%3Cpath d='M6 9l6 6 6-6'/%3E%3C/svg%3E");
    background-repeat: no-repeat;
    background-position: right 12px center;
  }
  .form-select:focus { border-color: var(--accent); }
  .form-textarea {
    width: 100%; padding: 10px 12px; background: var(--surface2);
    border: 1px solid var(--border); border-radius: 8px;
    color: var(--text); font-size: 13px; font-family: var(--mono);
    outline: none; resize: vertical; min-height: 80px; line-height: 1.5;
    transition: border-color .2s;
  }
  .form-textarea:focus { border-color: var(--accent); }
  .form-check {
    display: flex; align-items: center; gap: 8px;
  }
  .form-check input[type="checkbox"] {
    width: 16px; height: 16px; accent-color: var(--accent);
  }
  .form-check label { font-size: 13px; cursor: pointer; }
  .form-row { display: flex; gap: 12px; }
  .form-row > * { flex: 1; }

  /* ── Messages Builder ── */
  .messages-list { display: flex; flex-direction: column; gap: 8px; margin-bottom: 12px; }
  .msg-item {
    display: flex; gap: 8px; align-items: flex-start;
    background: var(--surface2); border: 1px solid var(--border);
    border-radius: 8px; padding: 10px 12px;
  }
  .msg-item select {
    padding: 6px 8px; background: var(--bg); border: 1px solid var(--border);
    border-radius: 6px; color: var(--text); font-size: 12px;
    outline: none; min-width: 90px;
  }
  .msg-item textarea {
    flex: 1; padding: 6px 8px; background: var(--bg); border: 1px solid var(--border);
    border-radius: 6px; color: var(--text); font-size: 13px; font-family: var(--font);
    outline: none; resize: vertical; min-height: 36px; line-height: 1.4;
  }
  .msg-item textarea:focus { border-color: var(--accent); }
  .msg-remove {
    padding: 4px 8px; background: transparent; color: var(--text2);
    border-radius: 4px; font-size: 16px; line-height: 1;
    transition: color .2s;
  }
  .msg-remove:hover { color: var(--red); }
  .add-msg-btn {
    padding: 8px 14px; background: var(--surface2); border: 1px solid var(--border);
    border-radius: 8px; color: var(--text2); font-size: 12px; font-weight: 500;
    transition: all .2s;
  }
  .add-msg-btn:hover { border-color: var(--accent); color: var(--accent); }

  /* ── Action Buttons ── */
  .send-btn {
    padding: 10px 24px; background: var(--accent); color: #fff;
    border-radius: 8px; font-size: 13px; font-weight: 600;
    transition: background .2s; margin-top: 8px;
  }
  .send-btn:hover { background: var(--accent-hover); }
  .send-btn:disabled { opacity: .5; cursor: not-allowed; }
  .send-btn.loading { position: relative; color: transparent; }
  .send-btn.loading::after {
    content: ''; position: absolute; inset: 0; margin: auto;
    width: 18px; height: 18px; border: 2px solid rgba(255,255,255,.3);
    border-top-color: #fff; border-radius: 50%;
    animation: spin .6s linear infinite;
  }
  @keyframes spin { to { transform: rotate(360deg); } }

  /* ── Response Panel ── */
  .response-panel {
    margin-top: 16px; border-top: 1px solid var(--border); padding-top: 16px;
    display: none;
  }
  .response-panel.visible { display: block; }
  .response-header {
    display: flex; align-items: center; gap: 10px; margin-bottom: 10px;
  }
  .response-status {
    font-size: 12px; font-weight: 700; padding: 3px 10px;
    border-radius: 6px; font-family: var(--mono);
  }
  .status-ok { background: var(--green-dim); color: var(--green); }
  .status-err { background: var(--red-dim); color: var(--red); }
  .response-time { color: var(--text2); font-size: 12px; }
  .response-body {
    background: var(--bg); border: 1px solid var(--border);
    border-radius: 8px; padding: 14px 16px;
    font-family: var(--mono); font-size: 12.5px; line-height: 1.6;
    white-space: pre-wrap; word-break: break-word;
    max-height: 400px; overflow-y: auto; color: var(--text);
  }
  .copy-resp-btn {
    margin-left: auto; padding: 5px 10px; background: var(--surface2);
    border: 1px solid var(--border); border-radius: 6px;
    color: var(--text2); font-size: 11px; transition: all .2s;
  }
  .copy-resp-btn:hover { border-color: var(--accent); color: var(--accent); }

  /* ── Slider ── */
  .slider-row { display: flex; align-items: center; gap: 12px; }
  .slider-row input[type="range"] {
    flex: 1; accent-color: var(--accent); height: 4px;
  }
  .slider-val {
    font-family: var(--mono); font-size: 13px; font-weight: 600;
    min-width: 36px; text-align: right;
  }

  /* ── Footer ── */
  .footer {
    text-align: center; padding: 24px; color: var(--text2);
    font-size: 12px; border-top: 1px solid var(--border);
    margin-top: 32px;
  }

  /* ── Responsive ── */
  @media (max-width: 600px) {
    .main-content { padding: 16px; }
    .topbar { padding: 12px 16px; }
    .endpoint-desc { display: none; }
    .form-row { flex-direction: column; }
    .server-info { flex-direction: column; align-items: flex-start; }
  }
</style>
</head>
<body>

<!-- ══════ Auth Screen ══════ -->
<div id="auth-screen">
  <div class="auth-card">
    <div class="auth-logo">◆</div>
    <div class="auth-title">Prism API Playground</div>
    <div class="auth-sub">Enter the access code shown in the Gateway screen of the Prism app to connect.</div>
    <input id="auth-code" class="auth-input" type="text" maxlength="6"
           placeholder="000000" autocomplete="off" autofocus>
    <button id="auth-btn" class="auth-btn" onclick="authenticate()">Connect</button>
    <div id="auth-error" class="auth-error"></div>
  </div>
</div>

<!-- ══════ Main Screen ══════ -->
<div id="main-screen">
  <div class="topbar">
    <div class="topbar-logo">◆</div>
    <span class="topbar-title">Prism API</span>
    <span id="conn-badge" class="topbar-badge badge-connected">Connected</span>
    <span class="topbar-spacer"></span>
    <span id="base-url" class="topbar-url"></span>
    <button class="disconnect-btn" onclick="disconnect()">Disconnect</button>
  </div>

  <div class="main-content">

    <!-- Server Info -->
    <div class="server-info">
      <div class="info-item">
        <span class="info-label">Base URL</span>
        <span id="info-url" class="info-value"></span>
      </div>
      <div class="info-item">
        <span class="info-label">Auth</span>
        <span class="info-value" style="color:var(--green)">✓ Authenticated</span>
      </div>
      <div class="info-item">
        <span class="info-label">Protocol</span>
        <span class="info-value">OpenAI-Compatible</span>
      </div>
    </div>

    <!-- ── GET /health ── -->
    <div class="endpoint-card" id="card-health">
      <div class="endpoint-header" onclick="toggleCard('card-health')">
        <span class="method-badge method-get">GET</span>
        <span class="endpoint-path">/health</span>
        <span class="endpoint-desc">Health check</span>
        <span class="endpoint-chevron">▼</span>
      </div>
      <div class="endpoint-body">
        <p style="color:var(--text2);font-size:13px;margin-bottom:14px">
          Returns server status. No authentication required.
        </p>
        <button class="send-btn" onclick="sendHealth(this)">Send Request</button>
        <div class="response-panel" id="resp-health">
          <div class="response-header">
            <span class="response-status" id="resp-health-status"></span>
            <span class="response-time" id="resp-health-time"></span>
            <button class="copy-resp-btn" onclick="copyResponse('resp-health-body')">Copy</button>
          </div>
          <pre class="response-body" id="resp-health-body"></pre>
        </div>
      </div>
    </div>

    <!-- ── GET /v1/models ── -->
    <div class="endpoint-card" id="card-models">
      <div class="endpoint-header" onclick="toggleCard('card-models')">
        <span class="method-badge method-get">GET</span>
        <span class="endpoint-path">/v1/models</span>
        <span class="endpoint-desc">List available models</span>
        <span class="endpoint-chevron">▼</span>
      </div>
      <div class="endpoint-body">
        <p style="color:var(--text2);font-size:13px;margin-bottom:14px">
          Lists all AI models available on this device.
        </p>
        <button class="send-btn" onclick="sendModels(this)">Send Request</button>
        <div class="response-panel" id="resp-models">
          <div class="response-header">
            <span class="response-status" id="resp-models-status"></span>
            <span class="response-time" id="resp-models-time"></span>
            <button class="copy-resp-btn" onclick="copyResponse('resp-models-body')">Copy</button>
          </div>
          <pre class="response-body" id="resp-models-body"></pre>
        </div>
      </div>
    </div>

    <!-- ── POST /v1/chat/completions ── -->
    <div class="endpoint-card" id="card-chat">
      <div class="endpoint-header" onclick="toggleCard('card-chat')">
        <span class="method-badge method-post">POST</span>
        <span class="endpoint-path">/v1/chat/completions</span>
        <span class="endpoint-desc">Chat completions</span>
        <span class="endpoint-chevron">▼</span>
      </div>
      <div class="endpoint-body">
        <p style="color:var(--text2);font-size:13px;margin-bottom:14px">
          Send a chat completion request. Supports streaming (SSE) and non-streaming responses.
        </p>

        <!-- Model -->
        <div class="form-group">
          <label class="form-label">Model</label>
          <div style="display:flex;gap:8px">
            <select id="chat-model" class="form-select" style="flex:1">
              <option value="auto">auto (default)</option>
            </select>
            <button class="add-msg-btn" onclick="loadModels()" style="white-space:nowrap" title="Refresh model list">
              ↻ Refresh
            </button>
          </div>
          <div id="model-status" style="font-size:11px;color:var(--text2);margin-top:4px;min-height:16px"></div>
        </div>

        <!-- Messages -->
        <div class="form-group">
          <label class="form-label">Messages</label>
          <div class="messages-list" id="messages-list">
            <div class="msg-item">
              <select><option>system</option><option>user</option><option>assistant</option></select>
              <textarea rows="1" placeholder="Message content...">You are a helpful assistant.</textarea>
              <button class="msg-remove" onclick="removeMsg(this)">×</button>
            </div>
            <div class="msg-item">
              <select><option>user</option><option>system</option><option>assistant</option></select>
              <textarea rows="1" placeholder="Message content...">Hello! What can you do?</textarea>
              <button class="msg-remove" onclick="removeMsg(this)">×</button>
            </div>
          </div>
          <button class="add-msg-btn" onclick="addMessage()">+ Add Message</button>
        </div>

        <!-- Options Row -->
        <div class="form-row">
          <div class="form-group">
            <label class="form-label">Temperature</label>
            <div class="slider-row">
              <input type="range" min="0" max="2" step="0.1" value="0.7"
                     oninput="document.getElementById('temp-val').textContent=this.value">
              <span id="temp-val" class="slider-val">0.7</span>
            </div>
          </div>
          <div class="form-group">
            <label class="form-label">Max Tokens</label>
            <input id="chat-max-tokens" class="form-input" type="number"
                   value="1024" min="1" max="32768">
          </div>
        </div>

        <div class="form-group">
          <div class="form-check">
            <input type="checkbox" id="chat-stream" checked>
            <label for="chat-stream">Stream response (SSE)</label>
          </div>
        </div>

        <button class="send-btn" id="chat-send-btn" onclick="sendChat(this)">Send Request</button>

        <div class="response-panel" id="resp-chat">
          <div class="response-header">
            <span class="response-status" id="resp-chat-status"></span>
            <span class="response-time" id="resp-chat-time"></span>
            <button class="copy-resp-btn" onclick="copyResponse('resp-chat-body')">Copy</button>
          </div>
          <pre class="response-body" id="resp-chat-body"></pre>
        </div>
      </div>
    </div>

    <div class="footer">
      Prism AI Gateway &middot; OpenAI-Compatible API &middot; Running on localhost
    </div>
  </div>
</div>

<script>
// ─── State ───────────────────────────────────────────
let accessCode = '';
const BASE = window.location.origin;

// ─── Auth ────────────────────────────────────────────
document.getElementById('auth-code').addEventListener('keydown', e => {
  if (e.key === 'Enter') authenticate();
});

async function authenticate() {
  const code = document.getElementById('auth-code').value.trim();
  const errEl = document.getElementById('auth-error');
  if (!code) { errEl.textContent = 'Please enter an access code.'; return; }
  const btn = document.getElementById('auth-btn');
  btn.disabled = true; btn.textContent = 'Connecting...';
  try {
    const res = await fetch(BASE + '/api/auth', {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({code})
    });
    const data = await res.json();
    if (data.success) {
      accessCode = code;
      showMain();
    } else {
      errEl.textContent = data.message || 'Invalid access code.';
    }
  } catch (e) {
    errEl.textContent = 'Connection failed. Is the server running?';
  }
  btn.disabled = false; btn.textContent = 'Connect';
}

function showMain() {
  document.getElementById('auth-screen').style.display = 'none';
  document.getElementById('main-screen').style.display = 'block';
  document.getElementById('base-url').textContent = BASE;
  document.getElementById('info-url').textContent = BASE;
  // Auto-fetch models on connect
  loadModels();
}

function disconnect() {
  accessCode = '';
  document.getElementById('main-screen').style.display = 'none';
  document.getElementById('auth-screen').style.display = 'flex';
  document.getElementById('auth-code').value = '';
  document.getElementById('auth-error').textContent = '';
}

// ─── Endpoint Cards ──────────────────────────────────
function toggleCard(id) {
  document.getElementById(id).classList.toggle('open');
}

// ─── Helpers ─────────────────────────────────────────
function authHeaders() {
  return {'Authorization': 'Bearer ' + accessCode, 'Content-Type': 'application/json'};
}

function showResponse(prefix, status, ok, time, body) {
  const panel = document.getElementById('resp-' + prefix);
  panel.classList.add('visible');
  const statusEl = document.getElementById('resp-' + prefix + '-status');
  statusEl.textContent = status;
  statusEl.className = 'response-status ' + (ok ? 'status-ok' : 'status-err');
  document.getElementById('resp-' + prefix + '-time').textContent = time + 'ms';
  document.getElementById('resp-' + prefix + '-body').textContent =
    typeof body === 'string' ? body : JSON.stringify(body, null, 2);
}

async function copyResponse(id) {
  const text = document.getElementById(id).textContent;
  await navigator.clipboard.writeText(text);
}

// ─── GET /health ─────────────────────────────────────
async function sendHealth(btn) {
  btn.classList.add('loading'); btn.disabled = true;
  const t0 = performance.now();
  try {
    const res = await fetch(BASE + '/health');
    const data = await res.json();
    showResponse('health', res.status, res.ok, Math.round(performance.now() - t0), data);
  } catch (e) {
    showResponse('health', 'ERR', false, Math.round(performance.now() - t0), e.message);
  }
  btn.classList.remove('loading'); btn.disabled = false;
}

// ─── GET /v1/models ──────────────────────────────────
async function sendModels(btn) {
  btn.classList.add('loading'); btn.disabled = true;
  const t0 = performance.now();
  try {
    const res = await fetch(BASE + '/v1/models', {headers: authHeaders()});
    const data = await res.json();
    showResponse('models', res.status, res.ok, Math.round(performance.now() - t0), data);
  } catch (e) {
    showResponse('models', 'ERR', false, Math.round(performance.now() - t0), e.message);
  }
  btn.classList.remove('loading'); btn.disabled = false;
}

async function loadModels() {
  const select = document.getElementById('chat-model');
  const status = document.getElementById('model-status');
  const prev = select.value;
  status.textContent = 'Loading models…';
  status.style.color = 'var(--text2)';
  try {
    const res = await fetch(BASE + '/v1/models', {headers: authHeaders()});
    const data = await res.json();
    // Clear existing options
    select.innerHTML = '';
    if (data.data && data.data.length > 0) {
      data.data.forEach(m => {
        const opt = document.createElement('option');
        opt.value = m.id;
        const label = m.id + (m.provider ? '  [' + m.provider + ']' : '');
        opt.textContent = label;
        select.appendChild(opt);
      });
      // Restore previous selection if it still exists
      const ids = data.data.map(m => m.id);
      if (ids.includes(prev)) select.value = prev;
      status.textContent = data.data.length + ' model' + (data.data.length > 1 ? 's' : '') + ' available';
      status.style.color = 'var(--green)';
    } else {
      const opt = document.createElement('option');
      opt.value = 'auto'; opt.textContent = 'auto (default)';
      select.appendChild(opt);
      status.textContent = 'No models found — is a model loaded in the app?';
      status.style.color = 'var(--orange)';
    }
  } catch (e) {
    status.textContent = 'Failed to fetch models';
    status.style.color = 'var(--red)';
  }
}

// ─── Messages Builder ────────────────────────────────
function addMessage() {
  const list = document.getElementById('messages-list');
  const item = document.createElement('div');
  item.className = 'msg-item';
  item.innerHTML = `
    <select><option>user</option><option>system</option><option>assistant</option></select>
    <textarea rows="1" placeholder="Message content..."></textarea>
    <button class="msg-remove" onclick="removeMsg(this)">×</button>`;
  list.appendChild(item);
}

function removeMsg(btn) {
  const list = document.getElementById('messages-list');
  if (list.children.length > 1) btn.closest('.msg-item').remove();
}

function getMessages() {
  const items = document.querySelectorAll('#messages-list .msg-item');
  return Array.from(items).map(item => ({
    role: item.querySelector('select').value,
    content: item.querySelector('textarea').value
  })).filter(m => m.content.trim());
}

// ─── POST /v1/chat/completions ───────────────────────
async function sendChat(btn) {
  btn.classList.add('loading'); btn.disabled = true;
  const t0 = performance.now();
  const bodyPanel = document.getElementById('resp-chat-body');
  const panel = document.getElementById('resp-chat');
  panel.classList.add('visible');
  bodyPanel.textContent = '';

  const messages = getMessages();
  if (!messages.length) {
    showResponse('chat', 400, false, 0, 'At least one message is required.');
    btn.classList.remove('loading'); btn.disabled = false;
    return;
  }

  const payload = {
    model: document.getElementById('chat-model').value || 'auto',
    messages,
    temperature: parseFloat(document.querySelector('#card-chat input[type=range]').value),
    max_tokens: parseInt(document.getElementById('chat-max-tokens').value) || 1024,
    stream: document.getElementById('chat-stream').checked,
  };

  try {
    if (payload.stream) {
      // Streaming via fetch + ReadableStream
      const res = await fetch(BASE + '/v1/chat/completions', {
        method: 'POST',
        headers: authHeaders(),
        body: JSON.stringify(payload),
      });

      const statusEl = document.getElementById('resp-chat-status');
      statusEl.textContent = res.status;
      statusEl.className = 'response-status ' + (res.ok ? 'status-ok' : 'status-err');

      if (!res.ok) {
        const errData = await res.text();
        bodyPanel.textContent = errData;
        btn.classList.remove('loading'); btn.disabled = false;
        return;
      }

      const reader = res.body.getReader();
      const decoder = new TextDecoder();
      let buffer = '';
      let fullContent = '';

      while (true) {
        const {done, value} = await reader.read();
        if (done) break;
        buffer += decoder.decode(value, {stream: true});
        const lines = buffer.split('\n');
        buffer = lines.pop() || '';

        for (const line of lines) {
          const trimmed = line.trim();
          if (!trimmed || !trimmed.startsWith('data:')) continue;
          const data = trimmed.slice(5).trim();
          if (data === '[DONE]') continue;
          try {
            const chunk = JSON.parse(data);
            const content = chunk.choices?.[0]?.delta?.content;
            if (content) {
              fullContent += content;
              bodyPanel.textContent = fullContent;
              bodyPanel.scrollTop = bodyPanel.scrollHeight;
            }
          } catch (_) {}
        }
      }

      document.getElementById('resp-chat-time').textContent =
        Math.round(performance.now() - t0) + 'ms';
    } else {
      // Non-streaming
      const res = await fetch(BASE + '/v1/chat/completions', {
        method: 'POST',
        headers: authHeaders(),
        body: JSON.stringify(payload),
      });
      const data = await res.json();
      showResponse('chat', res.status, res.ok, Math.round(performance.now() - t0), data);
    }
  } catch (e) {
    showResponse('chat', 'ERR', false, Math.round(performance.now() - t0), e.message);
  }
  btn.classList.remove('loading'); btn.disabled = false;
}
</script>
</body>
</html>
''';
