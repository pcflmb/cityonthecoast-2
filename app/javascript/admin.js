// Requires: @rails/ujs, cocoon gem

// import Rails from "@rails/ujs";
// Rails.start();

// Dynamic nested forms for event times
document.addEventListener("DOMContentLoaded", function () {
  // Initialize Cocoon for nested event times
  initializeNestedForms();

  // Auto-update position fields when times are added/removed
  updatePositions();

  // Add event listeners for dynamic position management
  document.addEventListener("cocoon:after-insert", function () {
    updatePositions();
  });

  document.addEventListener("cocoon:after-remove", function () {
    updatePositions();
  });

  // Confirmation dialogs
  initializeConfirmations();

  // Form validation
  initializeFormValidation();
});

function initializeNestedForms() {
  // Cocoon handles this automatically, but we can add custom behavior
  const addTimeButton = document.querySelector(
    '[data-association="event_times"]',
  );

  if (addTimeButton) {
    addTimeButton.addEventListener("click", function () {
      console.log("Adding new event time slot");
    });
  }
}

function updatePositions() {
  const timeFields = document.querySelectorAll(
    ".event-time-fields:not(.hidden)",
  );

  timeFields.forEach((field, index) => {
    const positionInput = field.querySelector('input[name*="[position]"]');
    if (positionInput) {
      positionInput.value = index;
    }
  });
}

function initializeConfirmations() {
  // Enhanced confirmation for destructive actions
  const deleteButtons = document.querySelectorAll("[data-confirm]");

  deleteButtons.forEach((button) => {
    button.addEventListener("click", function (e) {
      const message = this.getAttribute("data-confirm");
      if (!confirm(message)) {
        e.preventDefault();
        e.stopPropagation();
        return false;
      }
    });
  });
}

function initializeFormValidation() {
  const eventForm = document.querySelector(".event-form");

  if (!eventForm) return;

  eventForm.addEventListener("submit", function (e) {
    const errors = [];

    // Validate event name
    const nameField = eventForm.querySelector('input[name*="[name]"]');
    if (nameField && !nameField.value.trim()) {
      errors.push("Event name is required");
    }

    // Validate location
    const locationField = eventForm.querySelector('input[name*="[location]"]');
    if (locationField && !locationField.value.trim()) {
      errors.push("Location is required");
    }

    // Validate at least one event time
    const timeFields = eventForm.querySelectorAll(
      ".event-time-fields:not(.hidden)",
    );
    const validTimes = Array.from(timeFields).filter((field) => {
      const startInput = field.querySelector('input[name*="[start_time]"]');
      const destroyInput = field.querySelector('input[name*="[_destroy]"]');
      return (
        startInput &&
        startInput.value &&
        (!destroyInput || destroyInput.value !== "1")
      );
    });

    if (validTimes.length === 0) {
      errors.push("At least one event time is required");
    }

    // Validate time logic (end after start)
    validTimes.forEach((field) => {
      const startInput = field.querySelector('input[name*="[start_time]"]');
      const endInput = field.querySelector('input[name*="[end_time]"]');

      if (startInput && endInput && startInput.value && endInput.value) {
        const start = new Date(startInput.value);
        const end = new Date(endInput.value);

        if (end <= start) {
          errors.push("End time must be after start time");
        }
      }
    });

    if (errors.length > 0) {
      e.preventDefault();
      alert("Please fix the following errors:\n\n" + errors.join("\n"));
      return false;
    }
  });
}

// Helper: Show loading state during form submission
function showLoadingState(form) {
  const submitButton = form.querySelector('input[type="submit"]');
  if (submitButton) {
    submitButton.disabled = true;
    submitButton.value = "Saving...";
  }
}

// Helper: Format dates for display
function formatDateTime(dateString) {
  const date = new Date(dateString);
  return date.toLocaleString("en-US", {
    weekday: "short",
    month: "short",
    day: "numeric",
    year: "numeric",
    hour: "numeric",
    minute: "2-digit",
  });
}

// Preview image URL before saving
function initializeImagePreview() {
  const imageUrlInput = document.querySelector('input[name*="[image_url]"]');

  if (!imageUrlInput) return;

  // Create preview container if it doesn't exist
  let previewContainer = document.querySelector(".image-preview");
  if (!previewContainer) {
    previewContainer = document.createElement("div");
    previewContainer.className = "image-preview";
    imageUrlInput.parentNode.appendChild(previewContainer);
  }

  imageUrlInput.addEventListener("blur", function () {
    const url = this.value.trim();

    if (url) {
      previewContainer.innerHTML = `
        <img src="${url}"
             alt="Preview"
             style="max-width: 300px; margin-top: 1rem; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);"
             onerror="this.style.display='none'; this.parentNode.innerHTML='<p style=color:#C94B4B;>Invalid image URL</p>'">
      `;
    } else {
      previewContainer.innerHTML = "";
    }
  });
}

// Initialize image preview on page load
document.addEventListener("DOMContentLoaded", initializeImagePreview);

// Export for use in other scripts
window.AdminHelpers = {
  formatDateTime,
  showLoadingState,
  updatePositions,
};
