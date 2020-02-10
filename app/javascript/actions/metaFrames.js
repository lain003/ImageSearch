export const INITIALIZE_META_FRAMES = "INITIALIZE_META_FRAMES"
export const ADD_META_FRAMES = "ADD_META_FRAMES"
export const INITIALIZE_IMAGE_PATHS = "INITIALIZE_IMAGE_PATHS"

export const initializeMetaFrames = (metaFrames) => {
  return {
    type: INITIALIZE_META_FRAMES,
    payload: { metaFrames: metaFrames }
  };
}

export const addMetaFrames = (metaFrames) => {
  return {
    type: ADD_META_FRAMES,
    payload: { metaFrames: metaFrames }
  };
}

export const initializeImagePaths = (imagePaths) => {
  return {
    type: INITIALIZE_IMAGE_PATHS,
    payload: { imagePaths: imagePaths }
  };
}