import { connect } from 'react-redux';
import * as metaAction from '../actions/metaFrames';
import * as popupAction from '../actions/popup';
import MetaFrames from '../components/index/MetaFrames';

const mapStateToProps = state => {
  return {
    metaFrames: state.metaFrames.metaFrames,
    imagePaths: state.metaFrames.imagePaths
  }
}

const mapDispatchToProps = dispatch => {
  return {
    initializeMetaFrames: (metaFrames) => dispatch(metaAction.initializeMetaFrames(metaFrames)),
    addMetaFrames: (metaFrames) => dispatch(metaAction.addMetaFrames(metaFrames)),
    initializeImagePaths: (imagePaths) => dispatch(metaAction.initializeImagePaths(imagePaths)),
    popupShow: (metaFrame) => dispatch(popupAction.show(metaFrame)),
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(MetaFrames)