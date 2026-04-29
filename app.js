const watchlistItems = [
  "Credential stuffing attacks targeting SaaS logins",
  "Invoice phishing campaigns aimed at finance teams",
  "Unpatched VPN appliances exposed to the internet",
  "Social engineering through fake IT helpdesk calls",
];

const list = document.getElementById("watchlist");
watchlistItems.forEach((item) => {
  const li = document.createElement("li");
  li.textContent = item;
  list.appendChild(li);
});

const scoreMap = {
  mfa: { yes: 0, partial: 1, no: 2 },
  patching: { weekly: 0, monthly: 1, rarely: 2 },
  training: { yes: 0, sometimes: 1, no: 2 },
  backups: { tested: 0, untested: 1, none: 2 },
  endpoint: { all: 0, most: 1, few: 2 },
  irplan: { practiced: 0, documented: 1, none: 2 },
};

const getRiskMessage = (score) => {
  if (score <= 3) return "Low Risk: keep monitoring and maintain your controls.";
  if (score <= 7)
    return "Moderate Risk: strengthen identity controls and training cadence.";
  return "High Risk: prioritize MFA rollout, patching, and awareness training now.";
};

const form = document.getElementById("risk-form");
const result = document.getElementById("assessment-result");

form.addEventListener("submit", (event) => {
  event.preventDefault();

  const data = new FormData(form);
  const totalScore = [
    "mfa",
    "patching",
    "training",
    "backups",
    "endpoint",
    "irplan",
  ].reduce(
    (sum, key) => sum + scoreMap[key][data.get(key)],
    0,
  );

  result.textContent = getRiskMessage(totalScore);
});
