from utils import fetch_courses_and_sessions, run_extraction_image, run_modeling_job, make_tarfile, get_properties, evaluate_results
from multiprocessing import Pool

extract = False
model = True
eval = False

def main(dir):
    data_dir = get_properties()['data_dir']
    proc_data_dir = get_properties()['proc_data_dir']
    # feature extraction
    if extract:
        with Pool(int(get_properties()['max_num_cores'])) as pool:
            for c,s in fetch_courses_and_sessions(data_dir):
                pool.apply_async(run_extraction_image, [dir, c, s, data_dir, proc_data_dir])
            pool.close()
            pool.join()
        ## single-threaded version
        # for c, s in fetch_courses_and_sessions(data_dir):
        #     run_extraction_image(dir, c, s, data_dir, proc_data_dir)
    # modeling
    if model:
        with Pool(int(get_properties()['max_num_cores'])) as pool:
            for c, s in fetch_courses_and_sessions(data_dir):
                pool.apply_async(run_modeling_job, [dir, c, s, proc_data_dir])
            pool.close()
            pool.join()
        ## single-threaded version
        # for c, s in fetch_courses_and_sessions(data_dir):
        #     run_modeling_job(dir, c, s, proc_data_dir)
    # model evaluation
    if eval:
        evaluate_results()

if __name__ == "__main__":
    main(dir=get_properties()['local_working_directory'])