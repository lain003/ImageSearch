import { SHOW, HIDE } from '../actions/popup';

const initialState = {
  metaFrame: null,
  isShow: false
}

export const popupReducer = (state = initialState, action) => {
  switch (action.type) {
    case SHOW:
      const newState1 = Object.assign({}, state);
      newState1.isShow = true;
      newState1.metaFrame = action.payload.metaFrame;
      return newState1;
    case HIDE:
      const newState2 = Object.assign({}, state);
      newState2.isShow = false;
      newState2.metaFrame = null;
      return newState2;
    default:
      return state;
  }
};