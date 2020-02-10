import { INITIALIZE_META_FRAMES, ADD_META_FRAMES, INITIALIZE_IMAGE_PATHS } from '../actions/metaFrames';

const initialState = {
  metaFrames: [],
  imagePaths: {}
}

export const metaFramesReducer = (state = initialState, action) => {
  switch (action.type) {
    case INITIALIZE_META_FRAMES:
      const newState1 = Object.assign({}, state);
      newState1.metaFrames = action.payload.metaFrames;
      return newState1;
    case ADD_META_FRAMES:
      const newState2 = Object.assign({}, state);
      newState2.metaFrames = newState2.metaFrames.concat(action.payload.metaFrames);
      return newState2;
    case INITIALIZE_IMAGE_PATHS:
      const newState3 = Object.assign({}, state);
      newState3.imagePaths = action.payload.imagePaths;
      return newState3;
    default:
      return state;
  }
};