import { createStore as reduxCreateStore, combineReducers } from "redux";
import { metaFramesReducer } from "./reducers/metaFrames";
import { popupReducer } from "./reducers/popup";

export default function createStore() {
  const store = reduxCreateStore(
    combineReducers({
      metaFrames: metaFramesReducer,
      popup: popupReducer,
    }),window.__REDUX_DEVTOOLS_EXTENSION__ && window.__REDUX_DEVTOOLS_EXTENSION__()
  );

  return store;
}