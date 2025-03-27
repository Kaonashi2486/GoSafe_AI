import { FiUsers, FiAlertTriangle, FiMapPin } from "react-icons/fi";

const OverviewCards: React.FC = () => {
  return (
    <div className="grid md:grid-cols-3 gap-6">
      <div className="p-5 bg-gray-800 rounded-lg shadow-md flex items-center">
        <FiUsers className="text-blue-400 text-3xl mr-4" />
        <div>
          <h3 className="text-lg font-semibold">Total Users</h3>
          <p className="text-xl font-bold">12,345</p>
        </div>
      </div>
      <div className="p-5 bg-gray-800 rounded-lg shadow-md flex items-center">
        <FiAlertTriangle className="text-yellow-400 text-3xl mr-4" />
        <div>
          <h3 className="text-lg font-semibold">Alerts Sent</h3>
          <p className="text-xl font-bold">4,567</p>
        </div>
      </div>
      <div className="p-5 bg-gray-800 rounded-lg shadow-md flex items-center">
        <FiMapPin className="text-red-400 text-3xl mr-4" />
        <div>
          <h3 className="text-lg font-semibold">Tracked Locations</h3>
          <p className="text-xl font-bold">785</p>
        </div>
      </div>
    </div>
  );
};

export default OverviewCards;
