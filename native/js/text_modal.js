async function customPrompt() {
	return new Promise((resolve) => {

// Define a global variable to store the textarea value
var globalTextAreaResult;

// Create a semi-transparent background overlay
var overlay = document.createElement("div");
overlay.style.position = "fixed";
overlay.style.top = "0";
overlay.style.left = "0";
overlay.style.width = "100%";
overlay.style.height = "100%";
overlay.style.overflow = "auto";
overlay.style.backgroundColor = "rgba(0,0,0,0.5)";
overlay.style.zIndex = "9999"; // Ensure it's on top of other content

// Create the modal container
var modal = document.createElement("div");
modal.style.position = "fixed";
modal.style.top = "50%";
modal.style.left = "50%";
modal.style.transform = "translate(-50%, -50%)";
modal.style.backgroundColor = "#333"; // Set modal background to gray
modal.style.color = "white"; // Set text color to white for contrast
modal.style.padding = "20px";
modal.style.borderRadius = "8px";
modal.style.boxShadow = "0 2px 10px rgba(0, 0, 0, 0.1)";
modal.style.zIndex = "10000"; // Above the overlay
modal.style.minWidth = "50px"; // Set minimum width for the modal
modal.style.maxWidth = "80%"; // Limit modal width to a percentage of the viewport
modal.style.maxHeight = "80%"; // Limit modal height to a percentage of the viewport
modal.style.overflowY = "auto"; // Scroll if content is too long
modal.style.overflow = "auto";

// Create the title element
var modalTitle = document.createElement("h2");
modalTitle.textContent = "{atitle}";
modalTitle.style.marginTop = "0"; // Remove top margin
modalTitle.style.marginBottom = "5px"; // Add space below the title
modalTitle.style.color = "white"; // White text color for the title

// Create the subtitle element
var modalSubtitle = document.createElement("h3");
modalSubtitle.textContent = "{subtitle}";
modalSubtitle.style.marginTop = "0"; // Remove top margin
modalSubtitle.style.marginBottom = "15px"; // Add space below the subtitle
modalSubtitle.style.color = "lightgray"; // Light gray text color for the subtitle

// Create the textarea element
var textArea = document.createElement("textarea");
textArea.value = "{input}"
textArea.style.width = "100%"; // Make textarea full width
textArea.style.height = "100%"; // Make textarea full width
textArea.style.minHeight = "50px"; // Set a fixed height for the textarea
textArea.style.backgroundColor = "#444"; // Darker gray background for textarea
textArea.style.color = "white"; // White text color
textArea.style.border = "2px solid #666"; // Add a default border color
textArea.style.borderRadius = "4px"; // Rounded corners
textArea.style.resize = "none"; // Prevent resizing
textArea.style.boxShadow = "0 0 5px rgba(255, 255, 255, 0.3)"; // Subtle shadow for unfocused state

// Add hover effect for the textarea
textArea.addEventListener('mouseover', function() {
	textArea.style.borderColor = "#888"; // Change border color on hover
});

textArea.addEventListener('mouseout', function() {
	textArea.style.borderColor = "#666"; // Revert border color when not hovering
});

// Append the title, subtitle, and textarea to the modal
modal.appendChild(modalTitle);
modal.appendChild(modalSubtitle);
modal.appendChild(textArea);

// Create a close button
var closeButton = document.createElement("button");
closeButton.textContent = "{button}";
closeButton.style.marginTop = "20px";
closeButton.style.display = "block";
closeButton.style.marginLeft = "auto";
closeButton.style.marginRight = "auto";
closeButton.style.backgroundColor = "#555"; // Darker gray background for button
closeButton.style.color = "white"; // White text color for button
closeButton.style.border = "none";
closeButton.style.padding = "10px 20px";
closeButton.style.borderRadius = "5px";
closeButton.onclick = function() {
	// Set the global variable to the value of the textarea
	globalTextAreaResult = textArea.value;
	window.globalTextAreaResult = textArea.value;
	resolve(textArea.value); // Resolve the promise with the textarea value
	// Remove modal and overlay from the document
	document.body.removeChild(modal);
	document.body.removeChild(overlay);
};

// Append the close button to the modal
modal.appendChild(closeButton);

// Append the modal and overlay to the body
document.body.appendChild(overlay);
document.body.appendChild(modal);

	});
}
customPrompt();
