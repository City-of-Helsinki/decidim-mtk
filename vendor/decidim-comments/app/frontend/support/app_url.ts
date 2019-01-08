const appUrl = (path: string): string => {
  // Add the URL parameters to the URL
  if (window.location.search && window.location.search.length > 0) {
    path += window.location.search;
  }

  return path;
};

export default appUrl;
