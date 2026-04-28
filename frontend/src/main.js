import "./style.css";

const app = document.querySelector("#app");

app.innerHTML = `
  <section class="card">
    <h1>Vite + Hono API Demo</h1>
    <p class="endpoint">Request: GET <code>/api/hello</code> (via Vite Proxy)</p>
    <button id="call-api" type="button">Call API</button>
    <p id="status" class="status idle">Ready</p>
    <pre id="result" class="result">Click "Call API" to send request.</pre>
  </section>
`;

const callApiButton = document.querySelector("#call-api");
const status = document.querySelector("#status");
const result = document.querySelector("#result");

const setStatus = (text, className) => {
  status.textContent = text;
  status.className = `status ${className}`;
};

const callApi = async () => {
  setStatus("Calling backend API...", "loading");
  result.textContent = "Sending request to /api/hello ...";

  try {
    const response = await fetch("/api/hello");
    const data = await response.json();
    const now = new Date().toLocaleTimeString("ja-JP");

    setStatus(`Success (${response.status})`, "success");
    result.textContent = JSON.stringify(
      {
        path: "/api/hello",
        requestedAt: now,
        response: data,
      },
      null,
      2,
    );
  } catch (error) {
    setStatus("Failed to call API", "error");
    result.textContent = String(error);
  }
};

callApiButton.addEventListener("click", callApi);
