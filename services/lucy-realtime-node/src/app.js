const express = require('express');
const cors = require('cors');
const swaggerUi = require('swagger-ui-express');

const swaggerSpec = require('./config/swagger');
const realtimeRoutes = require('./routes/realtime.routes');
const internalRoutes = require('./routes/internal.routes');
const adminRoutes = require('./routes/admin.routes');
const { errorResponse } = require('./utils/response');

const app = express();

app.use(cors({
    origin: "https://lucyproject.vercel.app"
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'lucy-realtime-node' });
});

app.use('/api/realtime', realtimeRoutes);
app.use('/api/admin/realtime', adminRoutes);
app.use('/internal', internalRoutes);
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

app.use((req, res) => {
  res.status(404).json(errorResponse('Route not found'));
});

app.use((err, req, res, next) => {
  const statusCode = err.statusCode || 500;
  res.status(statusCode).json(errorResponse(err.message || 'Internal server error'));
});

module.exports = app;
