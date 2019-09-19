// Fins all section titles (presumably with anchors)
var sections = document.querySelectorAll("h2,h3");
var toc = document.getElementsByClassName("TableOfContents")[0];

window.onscroll = function() { onScroll()};

var previousSectionId

function onScroll() {
    // currentScroll is the number of pixels the window has been scrolled
    var currentScroll = window.pageYOffset;

    // currentSection is somewhere to place the section we must be looking at
    var currentSection

    // We check the position of each of the divs compared to the windows scroll positon
    sections.forEach(function(section) {
        // divPosition is the position down the page in px of the current section we are testing      
        var divPosition = section.offsetTop - 16;

        // If the divPosition is less the the currentScroll position the div we are testing has moved above the window edge.
        // the -1 is so that it includes the div 1px before the div leave the top of the window.
        if (divPosition - 1 < currentScroll) {
          // We have either read the section or are currently reading the section so we'll call it our current section
            currentSection = section;
          
          // If the next div has also been read or we are currently reading it we will overwrite this value again. This will leave us with the LAST div that passed.
        }
    });

    if (currentSection == null) {
        return;
    }
    var currentSectionId = currentSection.getAttribute('id')
    if (previousSectionId == currentSectionId) {
        return; // Nothing needs to be reloaded
    }
    previousSectionId = currentSectionId

    // Update the highlighted item in the document
    toc.querySelectorAll("a").forEach(function(item) {
        item.classList.remove("active");
    });
    var visible = toc.querySelectorAll("a[href='#"+currentSectionId+"']");
    visible[0].classList.add("active");
}