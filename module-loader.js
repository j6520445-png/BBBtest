// Module Loader - Loads and combines module parts

// Global function to load the game.love file
window.getSource = async function() {
  const response = await fetch('game.love');
  if (!response.ok) {
    throw new Error(`Failed to load game.love: ${response.status}`);
  }
  const arrayBuffer = await response.arrayBuffer();
  return new Uint8Array(arrayBuffer);
};

(function() {
  'use strict';

  // Track loading progress
  let loadedParts = 0;
  const totalParts = 2;
  const parts = [];

  // Function to load a script part
  function loadScriptPart(url, partIndex) {
    return new Promise((resolve, reject) => {
      fetch(url)
        .then(response => {
          if (!response.ok) {
            throw new Error(`Failed to load ${url}: ${response.status}`);
          }
          return response.text();
        })
        .then(text => {
          parts[partIndex] = text;
          loadedParts++;
          console.log(`Loaded part ${partIndex + 1}/${totalParts} (${(text.length / 1024 / 1024).toFixed(2)} MB)`);
          resolve();
        })
        .catch(error => {
          console.error(`Error loading ${url}:`, error);
          reject(error);
        });
    });
  }

  // Load all parts in parallel
  Promise.all([
    loadScriptPart('module.part1.js', 0),
    loadScriptPart('module.part2.js', 1)
  ])
  .then(() => {
    console.log('All module parts loaded. Executing combined module...');
    
    // Combine all parts
    const combinedCode = parts.join('');
    
    // Execute the combined code
    try {
      // Use indirect eval to execute in global scope
      (1, eval)(combinedCode);
      console.log('Module initialized successfully');
      
      // Trigger module ready event
      window.dispatchEvent(new Event('moduleReady'));
    } catch (error) {
      console.error('Error executing module:', error);
      throw error;
    }
  })
  .catch(error => {
    console.error('Failed to load module:', error);
    alert('Failed to load game module. Please refresh the page.');
  });
})();
