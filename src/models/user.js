module.exports = (sequelize, DataTypes) => {
  const User = sequelize.define(
    "User",
    {
      name: DataTypes.STRING,
      username: DataTypes.STRING,
      email: DataTypes.STRING,
      password: DataTypes.STRING,
      role: DataTypes.STRING,
      tin: DataTypes.STRING,
      nin: DataTypes.STRING,
      phone: DataTypes.STRING,
    },
    {
      tableName: "users",
    }
  );

  User.associate = function (models) {
    // associations go here
  };

  return User;
};
