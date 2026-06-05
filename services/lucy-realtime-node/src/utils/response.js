function successResponse(data = null, message = 'Success') {
  return {
    success: true,
    message,
    data,
  };
}

function errorResponse(message = 'Error', errors = null) {
  return {
    success: false,
    message,
    errors,
  };
}

module.exports = {
  successResponse,
  errorResponse,
};
