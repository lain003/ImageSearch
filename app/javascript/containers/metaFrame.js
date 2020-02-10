import { connect } from 'react-redux';
import { show } from '../actions/popup';
import MetaFrame from '../components/index/MetaFrame';

const mapStateToProps = state => {
  return {
    imagePaths: state.metaFrames.imagePaths
  }
}

const mapDispatchToProps = dispatch => {
  return {
    popupSnow: (metaFrame) => dispatch(show(metaFrame))
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(MetaFrame)