// Entry point for the build script in your package.json
import "@hotwired/turbo-rails";
import "./controllers";

// Fetch and render events
async function loadEvents() {
  const eventsContainer = document.getElementById("events-container");
  const loadingElement = document.getElementById("loading");
  const noEventsElement = document.getElementById("no-events");

  try {
    const response = await fetch("/api/events.json");
    if (!response.ok) {
      throw new Error("Failed to load events");
    }

    const data = await response.json();
    const events = data.events || [];

    // Hide loading
    loadingElement.style.display = "none";

    if (events.length === 0) {
      noEventsElement.style.display = "block";
      return;
    }

    // Sort events by earliest start date
    events.sort((a, b) => {
      const aStart = new Date(a.event_times[0].start);
      const bStart = new Date(b.event_times[0].start);
      return aStart - bStart;
    });

    // Render events
    events.forEach((event) => {
      const card = createEventCard(event);
      eventsContainer.appendChild(card);
    });
  } catch (error) {
    console.error("Error loading events:", error);
    loadingElement.innerHTML =
      '<p style="color: #C94B4B;">Failed to load events. Please try again later.</p>';
  }
}

// Create event card element
function createEventCard(event) {
  const card = document.createElement("div");
  card.className = "event-card";
  card.setAttribute("data-event-id", event.id);

  // Format all event times
  const timesHtml = event.event_times
    .map((time) => {
      const startDate = new Date(time.start);
      const endDate = time.end ? new Date(time.end) : null;
      return formatEventDate(startDate, endDate);
    })
    .join("<br>");

  // Build card HTML
  card.innerHTML = `
        <img src="${event.image}" alt="${event.name}" class="event-image" loading="lazy">
        <div class="event-content">
            <div class="event-date">${timesHtml}</div>
            <h2 class="event-title">${event.name}</h2>
            <div class="event-location">${event.location}</div>
            <div class="event-description">${event.description}</div>
            ${
              event.registrationLink
                ? `<a href="${event.registrationLink}" class="event-register" target="_blank" rel="noopener noreferrer">Register Now</a>`
                : ""
            }
        </div>
    `;

  return card;
}

// Format event date and time
function formatEventDate(startDate, endDate) {
  const options = {
    weekday: "short",
    month: "short",
    day: "numeric",
    hour: "numeric",
    minute: "2-digit",
  };

  const startStr = startDate.toLocaleString("en-US", options);

  if (endDate) {
    // Check if same day
    const sameDay = startDate.toDateString() === endDate.toDateString();

    if (sameDay) {
      const endTimeOptions = { hour: "numeric", minute: "2-digit" };
      const endTimeStr = endDate.toLocaleString("en-US", endTimeOptions);
      return `${startStr} - ${endTimeStr}`;
    } else {
      const endStr = endDate.toLocaleString("en-US", options);
      return `${startStr} - ${endStr}`;
    }
  }

  return startStr;
}

// Initialize on page load
document.addEventListener("DOMContentLoaded", loadEvents);
