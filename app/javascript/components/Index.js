import React from "react"
import MetaFrames from '../containers/metaFrames';
import PropTypes from "prop-types";
import createStore from "../createStore";
import {Provider} from "react-redux";

const store = createStore();
class Index extends React.Component {
  render() {
    return (
      <Provider store={store}>
        <MetaFrames meta_frames={this.props.meta_frames}
                    image_paths={this.props.image_paths}
        />
      </Provider>
    );
  }
}
Index.propTypes = {
  meta_frames: PropTypes.array,
  image_paths: PropTypes.object
};
export default Index;