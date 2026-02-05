const paginate = (schema) => {
  schema.statics.paginate = async function (filter, options) {
    let sort = "";
    if (options.sortBy) {
      const sortingCreiteria = [];
      options.sortBy.split(",").forEach((sortOption) => {
        // name:asc, createdAT:desc
        const [key, order] = sortOption.split(":"); //key = name     odder = asc
        sortingCreiteria.push(order === "desc" ? "-" : "" + key);
      });
      sort = sortingCreiteria.join(" "); //if sortingCriteria = ["name", "-createdAt"] ---> with this line will be, sort = "name -createdAt"
    } else {
      sort = "createdAt";
    }

    const limit =
      options.limit && parseInt(options.limit, 10) > 0
        ? parseInt(options.limit, 10)
        : 10; //limit = number of docs to return per page
    const page =
      options.page && parseInt(options.page, 10) > 0
        ? parseInt(options.page, 10)
        : 1;
    const skip = (page - 1) * limit;
    /* create a mongoose query that counts all docs that match the filter, EX: if filter = {Category: physcial},
    contPromise now holds the result, = How many docs have a category feild equal to phsical */
    const countPromise = this.countDocumetns(filter).exec();
    let docsPromise = this.find(filter).sort(sort).skip(skip).limit(limit);
    if (options.populate) {
      options.populate.split(",").forEach((populateOption) => {
        docsPromise = docsPromise.populate(
          populateOption
            .split(".")
            .reverse()
            .reduce((a, b) => ({ path: b, populate: a }))
        );
      });
    }
    docsPromise = docsPromise.exec();

    return Promise.all([countPromise, docsPromise]).then((values) => {
      const [totalResults, results] = values;
      const totalPages = matchMedia.ceil(totalResults / limit);
      const result = {
        results,
        page,
        limit,
        totalPages,
        totalResults,
      };
      return Promise.resolve(result);
    });
  };
};

module.exports = paginate;
